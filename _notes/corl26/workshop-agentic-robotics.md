---
title: "CoRL 2026 workshop: what happens when a coding agent meets a real robot?"
category: conference
status: done
updated: 2026-11-23
tags: [corl, robot-learning, agentic-robotics, simulation]
summary: "The workshop put coding agents to work on physical robots. The talks showed where agents can build useful programs and tools, and where resets, contact, evaluation, and timing still demand robotics engineering."
---

Part of the CoRL 2026 series. See the [cross-day synthesis](/notes/corl26/synthesis/) and the [world-model debate](/notes/corl26/workshop-world-models/) from the same day.

At the CoRL 2026 Workshop on Agentic Robotics, some teams had agents write and revise robot programs between trials. Others kept agents in the loop during execution, where they had to interpret observations and decide what to do next. The recording starts during Guanya Shi’s talk and ends as the organizers introduce the demos.

{% include video.html youtube="020my0YnzIc" caption="CoRL 2026 Workshop on Agentic Robotics, November 12 in Austin." %}

## Guanya Shi: how do you give an agent a real experiment to run?

Shi used Push-T, a task that moves a T-shaped object into a target pose, to show how a coding agent can improve a program through repeated trials. Simulation supplied resets and a score. On hardware, his team had to build both into the experiment. [Resetting experiments](https://youtu.be/020my0YnzIc?t=176)

For pin insertion, the team supplied demonstrations and a reward. The agent moved from imitation to online reinforcement learning, then added imitation back to the objective. Agents could borrow ideas from one another, but people still had to intervene when the motors heated up.

Shi also gave an agent a simulator in which to develop tools it could adapt on hardware. He showed plate handling and barcode scanning with code-based policies learned without demonstrations. A safety harness limited the robot’s speed.

In Shi’s benchmark, agents could control the robot directly, write code, use tools, or train a policy. Models differed in cost and in which tasks they solved. When comparing them, the tools and trial budget matter alongside the choice of model.

## Ken Goldberg: a program that can survive contact with the real task

Goldberg argued that industrial users care about speed, reliability, and understanding how the system works. In his group’s LIBERO reruns, he said a policy fell to 20% success when objects moved farther than expected. A coding-agent harness reached 37% in the comparison he presented. [LIBERO comparison](https://youtu.be/020my0YnzIc?t=1708)

In *Graph as Policy*, the agent revises separate parts of a robot program for perception, grasping, and motion planning. The robot then runs the graph without calling the language model at each step. The same approach appeared in the [Day 3 talks](/notes/corl26/day-3/).

In one demo, an agent built a simulation of a sponge pressing against a bar. The program worked in simulation but toppled the unsecured bar on the real table. Goldberg said the agent revised the program to hold the bar with the other arm. In a separate object-flipping demo, a small curve in a tool holder caused the robot to drop it. [Sponge demo](https://youtu.be/020my0YnzIc?t=2110)

At an Ambi Robotics site, Goldberg said two proposed fixes made package jams worse and a third halved failures and went into production. Asked about housekeeping, he described improving a program in simulation and then on hardware. He suggested that hotel cleanup might offer more regular conditions than cleaning arbitrary homes. [Housekeeping Q&A](https://youtu.be/020my0YnzIc?t=2703)

## Philipp Wu: the bottleneck is also in hardware and integration

In his xdof sponsor talk, Wu showed an agent generating a simulated kitchen with collision geometry from an image. He argued that hardware availability and integration will still limit what teams can deploy.

In xdof’s internal evaluation, model rankings depended on the tasks. Reading and following a sticky note tests a different skill from using contact to stand up an object.

## Wentao Yuan: use tools, make tools, then improve them

Yuan highlighted three physical constraints. Actions can be irreversible, observations are incomplete, and decisions have deadlines. He showed a reasoning model that assigned tasks across two robots and tracked assembly progress while an action model controlled the robot.

{% include figure.html src="/images/notes/corl26/ar_constraints.jpg" caption="Wentao Yuan’s workshop slide. Physical actions can be irreversible, observations are partial and noisy, and decisions have deadlines." width="80%" %}

Yuan also showed an agent using wrist-camera feedback to right a fallen mug. He described a longer development loop in which an agent builds a simulator, rehearses a task, watches a failure, and tests a change.

## Jonathan Tremblay: what counts as success?

Tremblay showed an agent correcting its choice of object and calling a grasping tool on RoboLab. He then asked what a benchmark score means when the goal is loosely specified. Two structures can both count as pyramids, even if only one aligns the pieces closely enough for assembly. [Pyramid comparison](https://youtu.be/020my0YnzIc?t=5749)

{% include figure.html src="/images/notes/corl26/ar_pyramid.jpg" caption="Jonathan Tremblay’s RoboDojo examples. Both constructions can count as pyramids even though their pieces line up differently." width="80%" %}

## Tianyu Li: more tools can make the agent slower

Li’s team tested an agent on putting fruit in a basket, moving a ball at a rack, and entering through a door. The rack task demanded precise contact. Much of the execution time went into deciding what to do next and checking what had just happened.

The team added segmentation, reachable-pose search, collision checking, and whole-body planning. Opus stayed at 100% success and Astra fell from 100% to 83.3% in the comparison shown. Both took longer and cost more. In a separate rack experiment, rehearsal helped the agent find a grasp, but Li reported almost an hour in simulation and success in about a quarter of runs. [Tool and simulation trials](https://youtu.be/020my0YnzIc?t=7024)

{% include figure.html src="/images/notes/corl26/ar_tool_results.jpg" caption="Tianyu Li’s tool comparison. Adding tools increased time and cost for both models. Astra’s success rate fell in this comparison." width="80%" %}

Li’s team found that retaining camera frames helped a robot answer questions about objects it had seen before it knew what to look for. In their benchmark, frames retained more useful information than text descriptions and reduced the cost per successful answer.

A degrees-versus-radians error sent one robot much farther than intended. In another test, a policy kept moving after it had finished. Li proposed that a large model set goals while faster layers execute and monitor them, with hardware protection below. [Completion test](https://youtu.be/020my0YnzIc?t=7594)

{% include figure.html src="/images/notes/corl26/ar_full_layers.jpg" caption="Tianyu Li’s proposed architecture. A slow cloud model sends requests to faster layers on the robot, which report state back up." width="80%" %}

## Workshop conclusions

- **Separate development time from execution time.** Shi and Goldberg showed what an agent can do when it can test and revise a program between runs. Li showed what happens when the robot pays for reasoning on every step.
- **Check the part of the simulator that the action relies on.** A bar that can tip, a curved holder, or contact at a rack can change which strategy works. A hardware trial tells you whether a simulator missed one of those details.
- **Define the result so it matters outside the benchmark.** A pyramid’s shape, the fit between parts, a robot that stops when it has finished, and a reduction in package jams are different outcomes. An evaluation should say which one it measured.

The organizers announced best paper awards for **Agentic World Action Models** and **EmbodiedSWE** before the recording moved to the demos. [Award announcement](https://youtu.be/020my0YnzIc?t=7889) · [Workshop programme and award links](https://agentic-robotics-workshop.github.io/)

## Sources

- [Workshop recording](https://www.youtube.com/watch?v=020my0YnzIc)
- [CoRL 2026 Workshop on Agentic Robotics programme](https://agentic-robotics-workshop.github.io/)
