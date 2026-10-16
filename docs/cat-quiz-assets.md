# Cat quiz artwork

The room was generated with the built-in ImageGen tool on 2026-10-16. Both cat expressions are cut directly from the user-provided quiz image, preserving the original pixels inside a transparent silhouette mask; they are not generated artwork. Text, question content, answer choices, timer, and progress are rendered separately in SwiftUI.

## Room background

Asset: `BrainRush/Assets.xcassets/CatRoomBackground.imageset/cat-room.png`

Prompt:

> Use case: illustration-story. Asset type: portrait mobile game background, no UI. Create a warm sunlit cozy room matching the room atmosphere in the user's cat quiz reference: large bright blue sky window on right, soft beige curtains, warm honey wooden floor, potted green plants at left and corners, gentle sunbeams and window shadows. High quality soft painterly anime game environment, softly defocused depth of field, rich warm cream and caramel tones with blue sky accents. Portrait 2:3 framing to fill phone. Calm uncluttered center behind overlay question cards. Room environment ONLY, no cat, no people, no text, no panels, no cards, no buttons, no border or watermark.

## Cat mascots — original image cutouts

- Happy: `BrainRush/Assets.xcassets/QuizCat.imageset/quiz-cat.png`
- Thinking: `BrainRush/Assets.xcassets/QuizCatThinking.imageset/quiz-cat-thinking.png`

Source: user attachment `codex-clipboard-3747cd86-cc0a-4585-8fb4-1a0393085931.png` (1536 × 1024).

The happy cat is extracted from the left panel; the thinking cat is extracted from the right panel. Core Graphics applies an outline mask and crops the original image, without redrawing, recoloring, or generating cat pixels. Areas hidden behind the original question banner remain cropped. The happy expression is used normally; the thinking expression is used after a missed answer.
