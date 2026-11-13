---
title: "CoRL 2026: where robot learning thinks it is going"
category: conference
status: done
updated: 2026-11-14
tags: [corl, robot-learning, synthesis]
summary: "Across all three days: what the field now treats as solved, what remains open, and where academia and industry agree and disagree."
---

Per-day notes: [Day 1](/notes/corl26/day-1/) · [Day 2](/notes/corl26/day-2/) · [Day 3](/notes/corl26/day-3/)

The Conference on Robot Learning (CoRL) is the main venue where machine-learning methods for robots are presented. The 2026 edition, held in Austin in November, was the largest so far. Attendance roughly doubled to about 4,800 people, submissions tripled to about 2,100 papers, and around 40% of attendees came from industry. This note pulls together what the three days of talks, keynotes, and the closing debate suggest about where the field is heading. It focuses on three questions: what researchers now treat as solved, what they treat as open, and where academic and industrial views differ.

## The background that shaped everything

About two months before the conference, a general-purpose frontier model called **GPT-6 Astra** was released. A frontier model here means a very large model trained mainly on internet-scale text, images, and code, of the kind that powers chat assistants and coding agents. Astra was not built for robots. When researchers connected it directly to simulated robots, it still completed far more tasks than the best purpose-built **robot foundation models**: one study reported 66% against 28%.

That result is the context for almost every talk at CoRL 2026. Robot learning has spent years building specialized models that take camera images and an instruction and output motor commands. If a general model can already do much of that, what is left for robotics research? Some students asked openly whether parts of their field were finished. The rest of the conference can be read as a long, collective answer to that question.

## A short primer on the ideas that recur

A few terms come up constantly in these notes. They are worth fixing before going further.

- **VLA (vision-language-action model).** A neural network that takes images and a language instruction ("put the cup on the shelf") and outputs robot actions. Most current robot foundation models are VLAs, usually built by fine-tuning a vision-language model on robot data. When no language input is involved, these are also called **large behavior models (LBMs)**.
- **Behavior cloning (BC) / imitation learning.** Training a policy to copy human demonstrations, usually collected by **teleoperation**: a person controls the robot remotely while its sensors and actions are recorded. This is the dominant way robot foundation models are trained today, and the closing debate was about whether it is enough.
- **Pretraining, mid-training, and post-training.** Pretraining learns general skills from large, diverse data. Mid-training adds broad robot or human data. Post-training (or fine-tuning) specializes the model to a particular robot or task, often with a small amount of in-domain data or with reinforcement learning.
- **Reinforcement learning (RL).** Learning by trial and error against a reward signal, rather than by copying demonstrations. It can exceed human performance but is expensive to run on real robots, so it is often done in simulation.
- **System 2, System 1, System 0.** A layered view of a robot's control stack, borrowed loosely from psychology. System 2 is slow, deliberate reasoning (planning a task, seconds to minutes). System 1 is fast, learned reaction (tens of decisions per second). System 0 is the reflex layer that handles contact and balance (hundreds of times per second).
- **Agentic LLM (ALM).** A language model that can call tools (code interpreters, simulators, motion planners) while it "thinks", and use their results to decide what to do next. GPT-6 Astra used as a robot controller is an ALM.
- **World model.** A model that predicts how the world will change, often as future video frames, given the robot's actions. Roboticists used to call this a *transition model*. It can be used to imagine outcomes before acting, to evaluate policies without real robots, or to generate synthetic training data. A **world-action model (WAM)** predicts future states and robot actions together.
- **Zero-shot generality.** The ability to carry out a new task with no task-specific training data at all. Frontier ALMs now show glimmers of it in robotics; VLAs mostly do not.
- **Sim-to-real gap.** The drop in performance when a policy trained in simulation is moved to a real robot, because simulated physics, sensors, and visuals never match reality exactly.
- **Egocentric human data.** Video recorded from a person's point of view (head or wrist cameras) while they do everyday tasks. It is much cheaper to collect than robot teleoperation, so companies now sell it at scale.
- **Shared autonomy / interventions.** A deployment mode in which a robot works autonomously while a remote human watches and takes over before a failure. The takeovers ("interventions") become new training data.

## A lens for reading the conference: "Postmodern robotics"

Two weeks before the conference, Leslie Kaelbling (MIT), one of the field's most senior figures and a speaker in the closing debate, circulated a short essay titled *Postmodern robotics*. It asks the same question as the conference ("problems long thought to be foundational or nearly impossible seem to be falling daily to agentic LLMs like Astra... What remains for us to do?"), and its framework makes the rest of these notes easier to read.

**Different robotics problems need different solutions.** Kaelbling separates four "niches":

| Niche | What it means | Main tools today |
|---|---|---|
| Known niche | A specific job, such as one factory task | Behavior cloning on demonstrations, or RL in a purpose-built simulator |
| Pretraining for generality | A model pretrained on many robots and tasks, then adapted to a new job with little data | Large VLAs and LBMs |
| Zero-shot generality | A robot that can do almost anything, almost anywhere, with no task-specific data | Agentic LLMs, which are starting to show this |
| Learning during deployment | A robot that learns from its mistakes and can be taught on the job | In-context learning, long histories, and memories written to text |

Much of the conference's apparent disagreement is really disagreement about which niche a speaker is targeting. The factory deployments of Day 2 (Walden, Boston Dynamics, DeepMind's kitting line) live in the first two niches. The frontier-model demonstrations live in the third. The closing debate's eventual common ground, that imitation works for "a boring problem... where you can collect enough data", is the first niche in plain words.

**Why agentic LLMs are suddenly good at zero-shot robotics.** Kaelbling gives four reasons, in order of importance:
1. **Knowledge.** Trained on the internet, they "know" what an eraser is, basic physics, and human purposes.
2. **Recursive computation.** They write and run their own code, which lets them plan over long horizons.
3. **Robotics tools.** Seventy-five years of robotics research is codified in software: controllers, kinematics, motion planners, simulators. Given a simulator, an ALM "can debug robot code just as it can debug regular code."
4. **Embodied data.** Astra was reportedly trained on some image-sequence and robot-action data, which improved its spatial understanding.

The fourth point was put to a direct test during the conference week. The robotics interpretability researcher Aiden Swann (Stanford, Goodfire) argued that "GPT-6 Astra's robotic capabilities are not emergent. It was trained on robotics specific data. So were GPT-6.1 Sol and Gemini Argon." His evidence was a simple probe. Fifty models were asked to compute a robot arm's hand position from its seven joint angles (forward and inverse kinematics) directly, without reasoning step by step. Three models stood out as clear outliers. The giveaway came when the arm's geometry was changed: those models kept predicting positions that fit one particular robot, the Franka Panda, rather than the arm they were actually given. That is the signature of a model that has memorized one robot's data, not one that reasons about kinematics in general.

The choice of robot is not surprising. Franka's own talk at the conference noted that more than half of single-arm CoRL papers in 2024 used its arm, so it dominates the robot data that exists. The probe cannot say exactly what data each lab used. It does show that the frontier models' robot skills are not purely emergent from general intelligence, and that robot data still matters, now collected inside frontier labs. That strengthens the data-centric side of the debate below, while knowledge, code-writing, and robotics tools still explain much of what these models do.

This explains several Day 1 and Day 3 results. NVIDIA's agent framework writes and tests skills in simulation. Graph-as-Policy builds a simulator from a phone video and debugs its program against it. DeepMind's frontier model built simulators from real robot logs to help develop its robot model. All three are ALMs using robotics tools, exactly as the essay describes.

**Her central claim: robot data is not the key.** "I don't think that robot data is the key to reducing this distance" between today's demonstrations and a truly general robot. The crucial ingredients, she argues, are **architecture, tools, and deployment constraints**. This is the sharpest intellectual fault line of the conference, and it is set out under the live debates below.

## What the field now treats as "solved", and how narrowly

Several speakers said that something was no longer a bottleneck. On closer inspection, each claim was limited to one part of one pipeline, and in every case the speakers themselves named the next bottleneck.

| Claim | What it actually covered | What the conference showed against it |
|---|---|---|
| High-level reasoning (System 2) is handled by frontier models | Breaking tasks into steps, writing robot code, understanding scenes and instructions | These models take seconds per decision, struggle with spatial and contact reasoning, and were not reliable enough for a production line without fine-tuning (Boston Dynamics). Fei-Fei Li: "not completely solved". |
| Compute for humanoid motion tracking | Training a controller that makes a humanoid follow any reference motion, now 3 hours on one GPU instead of a week on 128 | Transfer from simulation to real hardware, and task-level control, remain open |
| Data is no longer the bottleneck | Generating humanoid training motions from video-generation models | Boston Dynamics found that the *quality* of data, not its quantity, limits real performance |
| "The technology is ready" | Manufacturing tasks with a human supervisor ready to take over | Home robots were explicitly excluded by the speaker himself |
| Simulation alone is enough | Rigid pick-and-place transferred zero-shot to real robots | Deformable objects and tight insertions from camera input still fail |
| Benchmark scores show progress | No one defended this | Standard benchmarks can be "solved" by tiny models with shortcuts |

The pattern is the most useful finding of the conference. **Nothing was declared finished. Each time one obstacle fell, the obstacle moved.** For reasoning, it moved to timing. For training compute, it moved to sim-to-real transfer. For data volume, it moved to data quality. For AI capability, it moved to manufacturing robots in large numbers.

## What remains open

The following problems were raised by several speakers from both sectors, which makes them the best candidates for durable research directions.

1. **Fast, contact-aware control, and feedback flowing up the stack.** Robots fail most often at the moment of contact: grasping, inserting, wiping. Current policies mainly see images and joint positions, not forces. Several talks also observed that higher layers rarely learn that a lower layer has failed (for example, that a box has slipped from the hands).
2. **Reliability at production levels.** Out-of-the-box generalist models succeed often enough to impress but not enough to run a factory line. Online RL, learning from interventions, and safety monitoring were the favored tools.
3. **Composition.** Models that can do each part of a task (pick, recognize a color, count) often fail when one instruction requires all of them at once.
4. **Evaluation.** Fixed public benchmarks are overfitted, and frontier models can effectively "practice" on them without retraining. Hidden, diverse, or large real-world evaluations are replacing them.
5. **Data quality and valuation.** Knowing which data actually teaches a model something, rather than just collecting more of it.
6. **Memory and continual learning.** Remembering what happened earlier in a long task, and learning new skills without forgetting old ones.
7. **Multi-agent and human interaction.** Coordinating with other robots or people requires anticipating their choices, and the data needed grows quickly with the number of agents.
8. **Manufacturing and cost.** Building robots in volume, and reaching cycle times that make them economically worthwhile.

**How the open problems line up with Kaelbling's agenda.** Her essay lists what remains to be built for general robots. Nearly every item was echoed independently at the conference:

| Kaelbling's open problem | Where it surfaced at CoRL 2026 |
|---|---|
| Cognitive architectures with parallel processes at multiple time scales | Hang Zhao's System 0/1/2 layering by reaction time, and the missing feedback between layers (Day 1) |
| Computation speed: direct ALM control and "pre-coding" both take minutes to hours | Zhao's wall-clock experiment, where step-by-step frontier control collapsed (Day 1) |
| Persistent memory of people, places, and things | MEM, RobotTTT's long context, agent skill libraries stored as code (Days 1 and 3) |
| Rational behavior under uncertainty about the world and the goal | Burgard's call for calibrated uncertainty; intent clarification by asking questions (Days 1 and 3) |
| Planning under time constraints | Kaelbling's own debate line: an answer in an hour and a half means "you've missed the bus" (Day 3) |
| Safety guarantees for multi-process, largely learned systems | Martín-Martín: only probabilistic guarantees, judged by test suites (Day 2) |
| Operating while disconnected from the cloud | Zhao's split of compute between cloud, edge, and robot; NVIDIA's push to "own System 1, untethered" (Day 1) |
| Learning during deployment | Tedrake's deployment-data results; continual-learning work from Mehr and Martín-Martín (Days 1 and 2) |

The overlap is notable because the essay and the conference came at the question from different directions. One was a single researcher's reasoning, the other dozens of independent research groups and companies, and they arrived at much the same list.

## The live debates

**Is the path forward more data, or better architecture?** This is the deepest divide, and it cuts across the academic–industrial line. On one side, Russ Tedrake, Boston Dynamics, and Physical Intelligence's Chelsea Finn see reliability as coming from in-domain data, fine-tuning, and learning from deployment, and they presented production results to back it. On the other, Kaelbling argues that robot data will not close the gap to general robots, and that the missing pieces are architecture (fast and slow processes running in parallel), tools (memory, reasoning under uncertainty, time-aware planning), and deployment constraints (safety, disconnected operation). Hang Zhao's layering and NVIDIA's frontier-model-plus-local-model design sit between the two: architecture-first, but with a learned, data-hungry fast layer. The two positions mostly target different niches, which is why both can be right. The open question is which approach will extend to the zero-shot general robot that both sides ultimately want.

**Should a frontier model or a specialized model be the robot's "brain"?** Google DeepMind argued that robotics is ultimately "an intelligence problem" and that general frontier models will absorb more of it over time, a version of the AI field's "bitter lesson" that general methods eventually beat hand-built ones. Boston Dynamics, working on a real production line, found that no frontier model was reliable enough without fine-tuning. The claim that frontier models were themselves trained on robot data (see the lens section above) also blurs the distinction: a frontier "brain" may owe its robot skills to the same kind of data as a specialized one. AMD's Lisa Su predicted that specialized models will win wherever cost, power, and latency matter. The position that most speakers converged on is a **layered hybrid**: a frontier model reasons, writes code, and supervises, while a smaller, fast, locally owned model controls the robot.

**Is data from real deployments worth what it costs?** Collecting data on a real factory floor is slow and expensive, and skeptics argue that once a robot succeeds 99% of the time it stops producing useful failures to learn from. Russ Tedrake (MIT and Walden Robotics) presented an experiment that cut the other way. Stronger pretrained models produced *less* intervention data but *improved more* from it, which suggests that deployment data becomes more valuable as base models get better.

**Where should training data come from?** Teleoperation is accurate but slow and costly, and few speakers saw it as scalable on its own. Human egocentric video showed clean scaling trends for dexterous manipulation. Simulation is credible for rigid tasks. Deployment data is seen as the most valuable, and generic "mid-training" data is becoming a commodity that anyone can buy.

**Will imitation plus fine-tuning produce commercially viable generalist robots?** This was the closing debate (see [Day 3](/notes/corl26/day-3/)). Both sides agreed that the recipe can work for narrow, safe tasks where enough data can be collected. They disagreed on whether it leads to broad generality, and the audience sided with the skeptics before and after the debate.

**Can academia keep up?** Training the largest models costs far more than any university lab can spend. Wolfram Burgard called for "a CERN of robotics", a shared international effort. Fei-Fei Li described the underfunding of public-sector compute as "one of the biggest misses in the most important moment in history for AI". Tedrake expected large-model training to consolidate into a few companies, and argued that academia's distinctive role is to understand what these systems are actually doing.

## Academia and industry, side by side

| | Industry emphasis | Academic emphasis |
|---|---|---|
| Frontier models | A free upper layer to build on | A shock that redirects research priorities |
| How progress is measured | Uptime, intervention rate, cycle time against economic targets | Statistical validity, diagnosing *why* models fail |
| Data | Volume of human video and deployment data | What data teaches, and how to value it |
| Sensing | Mostly cameras plus joint positions | Touch, force, and calibrated uncertainty |
| Time horizon | Products in 2027 and 2028 | Problems on a ten-year scale |

The two sectors are less opposed than complementary. Industry is setting near-term targets and producing the first real production metrics. Academia is defining what counts as genuine progress and working on the problems that scale alone does not appear to fix.

## Where a research bet looks strongest

The problems named most consistently, by both sectors, were **contact and touch, composition, interaction with other agents, continual learning, and evaluation**. A second promising area is work that sits *beneath* frontier models (fast control, and the interface that reports failures upward) or *around* them (agents that verify and repair behavior, and methods that decide which data is worth collecting). Speakers across the program also expected the next CoRL to look very different, which is itself a reason to favor problems that will remain hard regardless of which model wins.
