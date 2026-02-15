# Mastermind — Entropy-Maximizing AI

A Flutter implementation of the classic Mastermind code-breaking game where a
human and an entropy-maximizing AI take turns as codebreaker, then compare
scores.

- **4 pegs**, **6 colors**, **1296 possible codes** (6⁴, with repetition)
- AI solves any code in **≤ 5 guesses on average** (≤ 6 worst case)

```
flutter run
```

---

## The 14 Possible Replies

After every guess, the codemaker responds with a pair **(b, w)**:

| Symbol | Meaning |
|--------|---------|
| **b** (black pegs) | Correct color in the correct position |
| **w** (white pegs) | Correct color, but wrong position |

The obvious constraint is **b + w ≤ 4**, which gives 15 pairs:

```
(0,0) (0,1) (0,2) (0,3) (0,4)
(1,0) (1,1) (1,2) (1,3)
(2,0) (2,1) (2,2)
(3,0) (3,1)  ← impossible!
(4,0)
```

But **(3, 1) is impossible**: if 3 pegs are exact-position matches, the 4th peg
occupies the only remaining slot. It either matches (→ 4,0) or doesn't
(→ 3,0). It cannot be "right color, wrong position" because there is no other
position it could go to. This eliminates one pair, leaving exactly
**14 distinct feedbacks**.

These 14 feedbacks form the **reply alphabet** of the game — the complete set
of signals the codemaker can send back after each guess.

---

## How the Solver Uses Entropy

### The core idea

After some number of guesses, the AI maintains a **remaining set S** — the
codes still consistent with all feedback received so far. Initially |S| = 1296.
The AI's job is to choose the next guess g that eliminates as many
possibilities as possible, *regardless of what the codemaker replies*.

Shannon entropy gives a principled way to measure this: it quantifies the
**expected information gain** of asking a particular question.

### Partitioning by feedback

For a candidate guess g and remaining set S, each code s ∈ S produces a
deterministic feedback f(g, s). This partitions S into up to 14 buckets — one
per possible reply:

```
S = S₁ ∪ S₂ ∪ … ∪ S₁₄

where  Sᵢ = { s ∈ S : f(g, s) = rᵢ }
```

and r₁, r₂, …, r₁₄ are the 14 valid feedback values. Most buckets will be
empty for any given guess; in practice a guess might split S into 5–10
non-empty groups.

After the codemaker replies with some rᵢ, the AI discards every bucket except
Sᵢ and continues. The question is: **which guess g produces the most useful
partition?**

### The entropy formula

Treating each reply rᵢ as an outcome with probability pᵢ = |Sᵢ| / |S|, the
Shannon entropy of the partition is:

```
            14
H(g) =  −  Σ   pᵢ · log₂(pᵢ)         (ignoring empty buckets)
           i=1
```

This measures the **expected number of bits of information** the codemaker's
reply will reveal about the secret. The key properties:

| Partition shape | Entropy | Why |
|-----------------|---------|-----|
| One giant bucket (all codes give the same reply) | **0 bits** — the guess tells us nothing | The reply is predetermined; no uncertainty is resolved |
| All buckets equal size (perfectly uniform split) | **maximum** — every bit of the reply is informative | Each outcome is equally surprising; maximum uncertainty resolved |
| Somewhere in between | H increases as the split becomes more even | More balanced → more expected information |

The AI picks **g\* = argmax H(g)** — the guess whose reply, *on average over
all 14 possible replies weighted by their probability*, conveys the most
information.

### Why "average" is the right objective

A single guess can't guarantee a specific reply — the codemaker's response
depends on the secret, which is unknown. What the AI *can* control is the
partition structure. By maximizing entropy, the AI ensures that:

1. **No reply is wasted.** High entropy means many distinct replies are
   possible, each carrying information.
2. **No outcome is catastrophically bad.** A balanced partition means even the
   "worst" reply still eliminates a large fraction of S.
3. **Expected remaining uncertainty is minimized.** By the chain rule of
   entropy, maximizing H(g) is equivalent to minimizing the expected entropy of
   S *after* receiving the reply — i.e., the expected remaining uncertainty.

This is the same principle behind optimal binary search, 20 Questions, and
decision tree learning: **ask the question that, on average, halves your
uncertainty as aggressively as possible**.

### Worked example: first guess

On the first turn, |S| = 1296 and the total uncertainty is log₂(1296) ≈ 10.34
bits. The precomputed first guess (Red, Red, Blue, Green — an AABC pattern)
produces this partition:

```
Feedback (b,w)  │ Bucket size │   pᵢ
────────────────┼─────────────┼────────
    (0, 0)      │      81     │  0.063
    (0, 1)      │     276     │  0.213
    (0, 2)      │     222     │  0.171
    (0, 3)      │      44     │  0.034
    (0, 4)      │       2     │  0.002
    (1, 0)      │     182     │  0.140
    (1, 1)      │     230     │  0.177
    (1, 2)      │      84     │  0.065
    (1, 3)      │       4     │  0.003
    (2, 0)      │     105     │  0.081
    (2, 1)      │      40     │  0.031
    (2, 2)      │       5     │  0.004
    (3, 0)      │      20     │  0.015
    (4, 0)      │       1     │  0.001
────────────────┼─────────────┼────────
    Total       │    1296     │  1.000
```

All 14 feedbacks are reachable — the guess "activates" every reply channel.
The entropy works out to approximately **H ≈ 3.04 bits**, meaning the
codemaker's reply will on average reveal 3.04 of the 10.34 bits needed to
identify the secret. After the reply, the expected remaining set size drops
from 1296 to roughly 1296 / 2^3.04 ≈ 158.

### Tie-breaking

When two guesses have equal entropy, the solver prefers one that is **still in
the remaining set S**. Such a guess could itself be the secret, giving it a
chance to be correct immediately (yielding the 4,0 reply) while being equally
informative.

### Computational cost

Each turn, the solver evaluates all 1296 candidate guesses. For each candidate,
it computes feedback against every code in S:

```
Cost per turn = 1296 × |S| feedback computations
```

On the first turn this is 1296 × 1296 ≈ 1.68 million — which runs in
milliseconds on any modern device. As |S| shrinks exponentially with each
guess, later turns are much cheaper.

---

## Code Map

```
lib/
├── main.dart                         App entry, dark Material3 theme
├── models/
│   ├── code.dart                     PegColor enum, Code class, allCodes (1296)
│   ├── feedback.dart                 GuessFeedback record (b, w)
│   ├── guess_entry.dart              A guess paired with its feedback
│   └── match_state.dart              Scores for both rounds
├── game/
│   ├── game_engine.dart              computeFeedback(), validateFeedback()
│   └── ai_solver.dart                Entropy-maximizing solver
├── screens/
│   ├── home_screen.dart              Start match
│   ├── human_guesses_screen.dart     Round 1: human cracks computer's code
│   ├── computer_guesses_screen.dart  Round 2: AI cracks human's code
│   └── score_screen.dart             Final comparison
└── widgets/
    ├── peg_board.dart                Guess history
    ├── color_picker.dart             6-color selector
    ├── code_input.dart               4-peg input
    ├── feedback_display.dart         Black/white peg indicators
    ├── feedback_input.dart           +/− counters for Mode 2
    └── info_bar.dart                 Remaining count & bits
```

---

## References

- Shannon, C. E. (1948). *A Mathematical Theory of Communication*.
- Knuth, D. E. (1977). *The Computer as Master Mind*. Journal of Recreational
  Mathematics, 9(1), 1–6.
