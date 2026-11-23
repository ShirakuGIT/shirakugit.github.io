---
title: "CoRL 2026 workshop debate: do robots need world models?"
category: conference
status: done
updated: 2026-11-23
tags: [corl, robot-learning, world-models, debate]
summary: "The panel debated whether robots should predict the consequences of candidate actions explicitly, and what kinds of prediction might help with training, execution, and evaluation."
---

Part of the CoRL 2026 series. See [Day 3](/notes/corl26/day-3/) for the main-conference debate on commercial generalist robots, and the [Agentic Robotics workshop](/notes/corl26/workshop-agentic-robotics/) for examples of agents using simulation to develop robot programs.

Two containers look identical, but one is heavier. Georgia Chalvatzaki argued that a robot could probe an object, observe how it moves, and predict what will happen if it pushes again. Chelsea Finn argued that a policy can also learn to handle surprises by training to succeed at the task.

## The debate at a glance

**Moderator — Yunzhu Li.** Does reliable general-purpose behavior require a world model, or can a policy learn enough from observations, history, and memory?

| Assigned side and speaker | Main arguments |
| --- | --- |
| **World models**<br>Max Zhaoshuo Li | Generalist robots need to anticipate what their actions will do. Narrow post-training can favor one strategy at the expense of flexibility. Prediction and action selection can share a system, provided it understands how actions change the state. |
| **World models**<br>Georgia Chalvatzaki | Compare outcomes when a mistake is hard to undo. Probe the environment when appearance alone leaves relevant facts uncertain. Use a model with the detail the decision calls for, and use it to study failures and explore new situations. |
| **End-to-end policies**<br>Chelsea Finn | Train directly for task success. The pinwheel example showed a policy switching grippers after narrow post-training. Broad predictors need to cover outcomes a policy can learn to avoid. Narrow simulators can still help evaluate policies. |
| **End-to-end policies**<br>Vincent Sitzmann | Imitation and real-world practice may suffice. A predictor learns from the situations the policy visits and may need to keep learning as those situations change. Predictive abilities can emerge inside the agent without a separate model with a fixed state space. |

The workshop assigned these sides. The panelists gave their personal views in the closing round.

{% include video.html youtube="6lc4x4Fxvl8" caption="Do Robots Need World Models? CoRL 2026 workshop debate, November 12 in Austin." %}

## What did the panel mean by a world model?

A world model predicts what may happen after a candidate action, given what the robot has observed. A planner can ask what follows from pushing left or right. A policy chooses an action and may learn some of the same relationships internally. A world-action model can predict both future states and actions.

{% include figure.html src="/images/notes/corl26/wm_definition.jpg" caption="Workshop introduction. The slide illustrates two predicted outcomes of tossing a toy bear. The paths are illustrations, not measured trajectories." width="80%" %}

Moderator Yunzhu Li contrasted Go, where the rules specify state transitions, with pouring water, where the physics can be hard to model and a policy may need only a few cues.

{% include figure.html src="/images/notes/corl26/wm_panel.jpg" caption="The opening debate slide. The two sides framed the dispute as whether reliable general-purpose robots require a world model or can learn to act from history, context, and memory." width="80%" %}

## Opening arguments: compare futures or train the action directly?

**Max Li** argued that a generalist robot needs to anticipate consequences. He compared it to a coding agent that can anticipate what a line of code will do before running it.

**Finn** recalled using action-conditioned video models to plan for new objects and goals when policies were typically task-specific. She argued that modern generalist policies offer another route to transfer. Reinforcement learning on hardware can then optimize directly for reliability.

**Chalvatzaki** argued that an explicit model helps when the robot faces uncertainty or a mistake is hard to undo. A probe can reveal a difference in mass or friction. After a failure, a model can help investigate what would have happened under another action.

**Sitzmann** argued that imitation and real-world reinforcement learning might give a robot enough experience to act without a separate predictor. He expected prediction to emerge when it helps an agent reach its goals, and doubted engineers would have to choose the state space in advance.

## Rebuttals: does post-training make a policy brittle?

Max Li worried that narrow post-training would make a policy brittle. Finn expected broader post-training across tasks and environments to preserve more flexibility.

Finn gave the example of a robot assembling a pinwheel. The post-training data showed right-gripper insertion. When the robot dropped the pin on the left, it picked it up with the left gripper and inserted it. Finn said the reversal did not appear in training. The demo showed that one policy could recover in one unexpected situation. [Pinwheel example](https://youtu.be/6lc4x4Fxvl8?t=1235)

Chalvatzaki asked what a robot does when a familiar action becomes risky, such as when people are nearby. Sitzmann asked where a predictor gets its data. A new policy may visit states the old one rarely encountered, so the predictor may need to keep learning as the policy changes. [Sitzmann’s coverage argument](https://youtu.be/6lc4x4Fxvl8?t=1453)

## Audience questions: how much of the world should the robot predict?

Asked whether a video planner counts as a world model, Sitzmann distinguished a plausible path to a goal from a prediction about an action you specify. Max Li argued that a single system can support both, just as a language model’s predicted token can describe what happens next or specify a step to execute.

The moderator asked why build a model if demonstrations can get a policy working and the final test is on hardware. Chalvatzaki said the representation should fit the decision. A rough route to an elevator can be enough to start walking and update along the way. [Elevator example](https://youtu.be/6lc4x4Fxvl8?t=1669)

Could a simulator distinguish policy checkpoints more cheaply than hardware trials? Finn noted that a robot can focus its practice on pouring wine, while an evaluator may also have to predict what happens when a candidate policy knocks the glass off the table. Sitzmann added that the goal determines which details matter. [Finn’s evaluation argument](https://youtu.be/6lc4x4Fxvl8?t=1989)

Chalvatzaki suggested that curiosity-driven play could teach a robot about situations beyond its current task. The opposing concern was how much experience it would take to cover actions the robot may never need.

## Closing positions and vote

- **Max Li** said that understanding how actions change the state is fundamental. He distinguished this from generating plausible action-conditioned video.
- **Chalvatzaki** saw video as a useful starting point and emphasized the need to understand physical consequences well enough to reason about alternatives. She also saw value in continuing to push the limits of current policies.
- **Sitzmann** took a pragmatic view of deployment. If a model helps with an engineering problem, use it. He expected more general agents to develop predictive abilities as they learn, and doubted that those agents would rely on a predictor with a state space fixed by engineers.
- **Finn** expected narrow simulations to be useful for evaluation and saw promise in training alongside video. She doubted that world models are strictly necessary.

The moderator held another show of hands and observed fewer hands on both sides. He gave no counts. [Closing round and vote](https://youtu.be/6lc4x4Fxvl8?t=2616)

## Workshop conclusions

1. **For execution, test the decision the model is meant to improve.** For the two containers, does predicting and probing help the robot choose a better push when it cannot see the difference in mass?
2. **For training, count the physical experience.** Compare how many real trials each approach needs to reach the same reliability, including the experience used to build or correct the model.
3. **For evaluation, compare the results with hardware.** A narrow simulator could be valuable if it ranks policies in the same order as hardware trials. Test that agreement when the policy makes unfamiliar mistakes.

## Sources

- [Debate recording](https://www.youtube.com/watch?v=6lc4x4Fxvl8)
- [Workshop programme, four motions, and assigned sides](https://do-robots-need-world-models.github.io/)
