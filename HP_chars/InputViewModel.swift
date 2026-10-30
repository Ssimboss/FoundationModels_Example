//
//  InputViewModel.swift
//  HP_chars
//
//  Created by Andrei Simvolokov on 16/05/2026.
//

import Combine
import FoundationModels

protocol InputRouterProtocol {
    func dismissInput()
}

final class InputViewModel: InputViewModelProtocol {
    private static let primaryButtonText = "OK"

    @Published
    var input: String = ""
    @Published
    private(set) var state: InputState = .loaded(primaryButtonText: primaryButtonText)

    private let filterRepository: FilterRepositoryProtocol
    private let router: InputRouterProtocol
    private static let instructions = """
        You translate a user's natural-language request about Harry Potter \
        characters into a FilterRequest: a list of constraints.

        Your job has three steps, and all of them matter:
        1. COMPLETE: emit one constraint for EVERY concept the user named. \
           Compound requests like "female humans" contain TWO concepts \
           (gender + species) and require TWO constraints. Do not stop \
           after the first concept — scan the entire prompt and translate \
           every descriptor.
        2. MINIMAL: do NOT invent constraints for dimensions the user did \
           not mention. If they did not say it, do not add it.
        3. CHECK: before answering, go through the list and remove every \
           constraint the request has no matching word for. Generic words \
           like "people" or "characters" match nothing. Keep:
           - .species only if the request names that species \
             (e.g. "human", "goblin", "ghost")
           - .gender only with a gender word ("male", "female", "man", \
             "woman", "boy", "girl")
           - .house only if the request names that house
           - .ancestry only with "muggleborn", "half-blood" or "pure-blood"
           - .isWizard only with "wizard", "witch", "muggle" or \
             "non-magical"
           - .isHogwartsStudent only with "student" or "students"
           - .isHogwartsStaff only with "teacher", "professor" or "staff"
           - .isAlive only with "alive", "living", "dead", "deceased", \
             "killed" or "died"

        If the user named nothing (e.g. "show everyone"), emit an empty list.

        Constraints across the list combine as AND. Multiple constraints \
        on the same dimension (e.g. two .house constraints) combine as OR \
        within that dimension.

        Vocabulary mapping (apply only when the user uses these words):
        - "alive" / "still alive" → .isAlive(true)
        - "dead" / "deceased" / "killed" → .isAlive(false)
        - "student" / "students" → .isHogwartsStudent(true)
        - "teacher" / "professor" / "staff" → .isHogwartsStaff(true)
        - "muggleborn" / "half-blood" / "pure-blood" → .ancestry(...)
        - "wizard" / "witch" (generic) → .isWizard(true)
        - "non-magical" / "muggle" (contrasted with magical) → \
          .isWizard(false)
        - House names (Gryffindor, Slytherin, Hufflepuff, Ravenclaw) → \
          .house(...)
        - Species names (human, goblin, ghost, dragon, etc.) → .species(...)
        - Gender words ("male", "female", "man", "woman", "boy", "girl") → \
          .gender(...)
        - Generic words ("people", "characters", "everyone", "all") → \
          no constraint

        Examples — note how each descriptor in the prompt maps to its own \
        constraint:

        - "Show all humans" → [.species(human)]
          (one concept: humans)

        - "Show all female humans" → [.gender(female), .species(human)]
          (two concepts: female + humans)

        - "Show everyone" → []
          (no concepts)

        - "characters in Hufflepuff" → [.house(Hufflepuff)]
          (one concept: Hufflepuff; "characters" is generic)

        - "Gryffindor students" → \
          [.house(Gryffindor), .isHogwartsStudent(true)]
          (two concepts: Gryffindor + students)

        - "male Gryffindor students" → \
          [.gender(male), .house(Gryffindor), .isHogwartsStudent(true)]
          (three concepts: male + Gryffindor + students)

        - "dead Slytherins" → [.house(Slytherin), .isAlive(false)]
          (two concepts: Slytherin + dead)

        - "alive female professors" → \
          [.isAlive(true), .gender(female), .isHogwartsStaff(true)]
          (three concepts: alive + female + professors)

        -Show "pure-blood wizards in Slytherin or Ravenclaw" → \
          [.ancestry(pure-blood), .isWizard(true), \
           .house(Slytherin), .house(Ravenclaw)]
          (four concepts: pure-blood + wizard + Slytherin + Ravenclaw)
        """

    init(
        filterRepository: FilterRepositoryProtocol,
        router: InputRouterProtocol
    ) {
        self.router = router
        self.filterRepository = filterRepository
    }

    func primaryButtonDidTap() {
        guard case .loaded = state else { return }
        let prompt = input
        state = .loading
        Task {
            do {
                // Fresh session per request so earlier prompts don't leak constraints into this one.
                let session = LanguageModelSession(instructions: Self.instructions)
                let response = try await session.respond(
                    to: prompt,
                    generating: FilterRequest.self
                )
                apply(filter: response.content.filter)
            } catch {
                apply(filter: nil)
            }
        }
    }
    
    @MainActor
    private func apply(filter: Filter?) {
        state = .loaded(primaryButtonText: Self.primaryButtonText)
        if let filter {
            filterRepository.filter.send(filter)
            router.dismissInput()
        }
    }
}
