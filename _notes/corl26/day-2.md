---
title: "CoRL 2026, Day 2: from demonstrations to deployments"
category: conference
status: done
updated: 2026-11-14
tags: [corl, robot-learning, deployment, reinforcement-learning]
summary: "Generalist robot models are useful out of the box but not reliable enough for production. Day 2 showed how that gap is closing, with production numbers from real factories."
---

Part of a three-day series. See the [cross-day synthesis](/notes/corl26/synthesis/) for background and definitions.

Day 1 established that general frontier models now handle much of a robot's high-level reasoning. Day 2 turned to a more practical question: **how do robot models become reliable enough to do real work?** A generalist model that succeeds 80% of the time is impressive in a lab demo, but useless on a factory line that cannot stop. The day's research sessions covered the tools for closing that gap: human video as training data, reinforcement learning after pretraining, force and touch, and humanoid control. The afternoon added production metrics from robots doing work in real factories.

## Human video as primary training data

Collecting robot demonstrations by teleoperation is slow, so researchers have long wanted to learn from ordinary videos of people. The obstacle is that human hands and robot hands differ in shape, and videos record motion but not the forces involved.

**EgoScale** used first-person human video as the *main* pretraining source for a dexterous robot hand. Hand and wrist motions were extracted from the video and mapped into the robot's action space. A small bridging dataset followed, pairing about 4 hours of robot teleoperation with 50 hours of matched human data. The bridge was carefully designed: humans and robot did the same tasks, and the humans were asked to move like the robot. The key finding was a clean **scaling law**: validation error fell steadily as the hours of human video grew, and real-robot success tracked that error. With this pipeline, a single teleoperated demonstration plus 100 human videos was enough to teach an unseen task such as folding a shirt.

{% include figure.html src="/images/notes/corl26/d2_egoscale_scaling.jpg" caption="Error falls log-linearly with hours of human pretraining video, and robot task completion rises with it." width="80%" %}

Other talks used people more selectively:
- One group predicted **where a person would look** before acting, arguing that intent transfers between human and robot bodies more easily than raw motion.
- Another trained a small "co-pilot" in simulation that handled delicate contact while a human teleoperator supplied the overall intent. This made teleoperation itself faster and more reliable: "you don't need to solve full autonomy to make teleoperation reliable."

**Why it matters.** EgoScale shows human video can be the main pretraining ingredient for dexterous manipulation, with predictable scaling, provided a small, deliberately aligned human–robot dataset bridges the two bodies. That's one demonstrated recipe, not yet a field-wide shift.

## Reinforcement learning on the hard part

**Physical Intelligence** stated the gap plainly. Their generalist models perform many tasks "out of the box", but not at the reliability real deployment needs, especially for precise or deformable work: threading a zip tie, or aligning a screwdriver before driving a screw. As they put it, "just collecting more demo data rarely solves the issue." Each such failure is too specific and too subtle.

Their answer is to add a small **reinforcement-learning module** on top of the frozen generalist model, trained online on the real robot and targeted only at the hardest segment of a task. The large model supplies a compact summary of what it sees and a proposed action. The small module learns, from success and failure, how to adjust that action. On an Ethernet-cable insertion task, human teleoperators needed a median of 146 steps and the fine-tuned generalist 228. The RL-trained policy needed 66, and **half of its attempts were faster than the fastest human demonstration.**

{% include figure.html src="/images/notes/corl26/d2_rlt_hist.jpg" caption="Distribution of task durations: human teleoperation (green), the generalist model (orange), and the RL-trained policy, whose median is far shorter than either." width="80%" %}

**Why it matters.** The emerging recipe is broad pretraining followed by targeted RL on the parts that matter. On this task, at least, the human demonstrations were the starting point, not the ceiling.

## Learning without starting over

**Roberto Martín-Martín** (UT Austin) gave an early-career keynote built on a simple premise. "Future robots may come with super powerful pre-trained models," but "no agent can be pre-trained in all possible futures." Every real deployment will meet a new body, home, or user. So the important property of a robot is not only what it can do today but its **learning potential**: how much new capability it gains from a given amount of new experience.

He organized his group's work around four questions:
1. *What should a robot be able to do before learning begins?* A space of coordinated movements learned in simulation let real robots learn contact-rich mobile tasks by RL in under an hour, with very few safety stops.
2. *What should a demonstration teach?* He cited a developmental-psychology finding that infants learn as well from *failed* adult demonstrations as from successful ones, which suggests they extract intent rather than copy motion. His group built a robot that learns a multi-step task from a single human video and uses safety models trained in simulation to adapt it.
3. *Which data should be used?* He argued that data should be valued by how much it improves the learner, not by how similar it looks to the target task. His group's method for this selected training data better than similarity-based rules, and an automated data-collection loop outperformed human experts.
4. *What should persist?* Small adapter modules trained with RL let a model learn new tasks with almost no forgetting.

Asked about safety guarantees, he said this approach can offer only probabilistic guarantees, and suggested that safety will be judged by test suites. He was candid that some unsafe events still occurred, and that his group is working toward more formal methods. The one-video learning demos involved search and backtracking, and the videos were sped up 40 times.

## Dexterity, force, and touch

A recurring theme of the contact-focused sessions was that **policies driven by vision and joint positions fail at the moment of contact**, and that relatively cheap changes help:
- One analysis found two distinct failure modes in VLAs on contact-rich tasks. The first is precision: actions must become tiny near contact, and the training setup made such small actions hard to generate. The second is force: force signals are sparse and change over time, so they need special handling. With both fixes, the method reached 66% success across five tasks and 2,500 real trials, 25 points above the best baseline.
- Low-cost robot arms that lack force sensors were taught to **estimate external force** from 10 minutes of free movement, enabling force feedback for the human teleoperator and force-aware training.
- Touch sensing worked much better when given distinct jobs: one signal tracking the steady contact state, another reacting to sudden changes. This reached 90.7% success on insertion tasks, against 46% for a simple combination of the same signals.
- A policy trained only in simulation learned half-millimeter-clearance assembly after a pretraining phase of "play": moving many objects to random poses. RL from scratch stayed at 0% after 24 hours of training.
- A post-hoc "force expert" bolted onto an already-trained model improved contact handling without losing its visual skills ([paper](https://arxiv.org/abs/2607.14236)).
- A warning from the deformables session: on [WireCraft](https://arxiv.org/abs/2606.18097), a benchmark for industrial wire insertion, every kind of policy did well when given the exact object state but "drops drastically" from camera input, and tight-clearance insertion "remains an open challenge". Adding simulated data raised real insertion success from 15% to 80%.

**Why it matters.** In these studies, contact is where today's models are weakest and where several near-term gains are available, often without retraining the underlying model.

Two other results bear on the frontier-model question. **DISCO**, an award finalist, combined tree search with learning for long multi-object tasks, and opened by quoting the bitter lesson's point that *search and learning* are what scale. That reads the lesson differently from DeepMind later in the day. A [neurosymbolic driving paper](https://arxiv.org/abs/2606.15251) reported that every frontier model it tried translated written traffic rules into formal logic perfectly, given one or two checks by a judge and verifier.

## Humanoids: data and compute

Two best-paper finalists made strong claims about humanoid robots:
- **GRAIL** (NVIDIA) used video-generation models to *generate* humanoid training data: sitting, climbing stairs, picking up objects. Motions were extracted from the generated video and filtered for physical validity. The resulting 35,000 motions trained policies that worked on real robots with no real-world data. The authors' stated vision is that "data is no longer the bottleneck". Asked what the bottleneck then becomes, they named the gap between simulation and reality.
- **SuperMimic** (UC Berkeley) trained a controller that makes a humanoid follow any reference motion, using a learned model of the robot's dynamics. It took **3 hours on one GPU**, compared with an established method that used 128 GPUs for a week. "We solved the compute problem," the presenter said, though the claim applies to this training step, not to robotics in general. He also noted a smaller dataset and a faster GPU, so it isn't a like-for-like comparison.

## Industry: who should be the robot's brain?

The afternoon sponsor talks gave the clearest view yet of industrial deployment, and revealed a genuine disagreement.

**Google DeepMind** presented Gemini Robotics 2.5. It performs more than 200 distinct tasks and kitted automotive parts autonomously at a 96% success rate on an active Mercedes-Benz production line, working with the robotics company Apptronik. The more striking claim was that their frontier model, Gemini 4 Argon, **helped build** it. Argon reconstructed simulations from real robot logs, described dexterous motions in fine detail, and acted as a research assistant that analyzed failures and proposed experiments. Their closing prediction was a version of the AI field's "bitter lesson": "frontier models will do more and more of robotics and the robot-specific models will be less and less prevalent," because "robotics ultimately is an intelligence problem." In the next breath came a caveat: "right now these models are still pretty slow and heavy... but this will get faster." DeepMind also showed safety work: the robot pauses when a hand enters its workspace, and an open benchmark tests resistance to jailbreaks.

{% include figure.html src="/images/notes/corl26/d2_gdm_bitter.jpg" caption="DeepMind's outlook: robotics as an intelligence problem that frontier models will increasingly absorb. (Google DeepMind)" width="75%" %}

**Boston Dynamics** reported an early deployment of its Atlas humanoid at Hyundai's plant in Savannah, Georgia, sequencing parts in the order an assembly line consumes them. The system runs one action model on the robot and a cloud "job harness" built on a fine-tuned Gemini model, with the job description written as an ordinary text prompt. Its findings tempered the optimism:
- **None of the frontier vision-language models tested was reliable enough without fine-tuning** to judge task completion or pick the right part.
- No action-model architecture "really excels". All needed substantial data, about 400 hours of teleoperation, to reach production reliability.
- End-to-end, Atlas completed 98.6% of tasks, though about 1 in 10 needed a brief human intervention, roughly one every 20 minutes. Each task took between one and two minutes, and the line ran at about 2 minutes per task where 1 minute is needed to be economically worthwhile.

They predicted Atlas's **first full 8-hour production shift in 2027**. Their two general lessons were that dividing manipulation into separate skills "is a fallacy because skills blend into each other," and that "behavior performance is more limited today by data quality than scale."

{% include figure.html src="/images/notes/corl26/d2_bd_results.jpg" caption="Atlas's end-to-end results on a real factory sequencing task: navigate, pick the correct part, scan it, and place it in the correct slot. (Boston Dynamics)" width="75%" %}

Other companies filled in the picture. **Tesla** described world models trained from scratch that let it test policies against rare events (a falling tree branch, an elephant on the road) and train on them, for both its Cybercab and Optimus robots. It said it is scaling Optimus manufacturing "to the order of millions" because robust policies require the physical robot at scale. Tesla added that the examples shown were "not that recent" and it couldn't present its latest results. **AgiBot** reported producing more than 20,000 general-purpose robots in three years, and a deployment-memory system that raised a convenience-store restocking task from 28.6% to 85.7% over five days. **Meta** is building a home humanoid that is "useful and delightful", but showed no product details. **Franka** noted that more than half of single-arm CoRL 2024 papers used its arm.

## Russ Tedrake: the case for deployment data

The day's main keynote came from **Russ Tedrake**, an MIT professor who in January co-founded **Walden Robotics**, a spin-out from the Toyota Research Institute. He opened with his campus experience on the first day of semester, overhearing a student say: "Dude, did you see that OpenAI just solved robotics?" He acknowledged that recent model releases had caused "a lot of angst." His own view was that the moment is an opportunity, provided the field plans for it.

Walden's founding beliefs were stated plainly. The technology is ready, with "no glass ceiling" if it is scaled. The next hurdle is turning general-purpose robots into products customers will pay for. A robotics company must be full-stack, able to fix hardware as readily as software. And **the most valuable data comes from real deployments.**

His first deployment loads heavy camshafts onto a Toyota machining line. Toyota chose the task because it topped the workers' complaint box, not because it suited robots. The line's requirements were 98.5% uptime, near-zero defects, zero safety incidents, and never stopping the line. The robots have been "in production since April working full shifts." With remote assistants ready to take over before a failure (an approach he likened to HG-DAgger), the line has never stopped, though autonomy alone is lower. The time between interventions has grown with every model generation, reaching about 340 seconds with 98% autonomy for the latest model. He estimated that this could let about three remote assistants supervise 50 robots, while calling that an operational challenge still to be met. New behaviors also appeared as models grew, such as looking around to find a hidden object, which "was a PhD thesis a few years ago."

He also talked about the people. On the first day in the factory, onlookers crowded around the humanoid, and he asked himself whether "we made a mistake making it look as human as we did." He decided on the spot: "just tighten screws for an hour. Make it really boring." Line workers now name the robots and put hats on them.

He then engaged directly with skeptics who argue that deployment data quickly stops being useful, crediting blog posts by [Kyle Vedder](https://vedder.io/misc/novelty_pump.html) and [Chris Paxton](https://itcanthink.substack.com/p/how-much-is-robot-deployment-data): production demands near-perfect success, which constrains tasks and leaves few failures to learn from. His experiment compared models pretrained on 1,000, 10,000, and 100,000 hours of external data, each deployed for 24 hours on new, hard tasks with human interventions. **The strongest model generated the least intervention data but improved the most.** He flagged a measurement caveat himself: operators intervene in long stretches on weak models and in quick nudges on strong ones, so the standard metric mixes model quality with operator behavior. He also scoped the claim: if your goal is the "shortest path to a zero-shot promptable [robot] in the home," his evidence "won't unconvince you."

{% include figure.html src="/images/notes/corl26/d2_russ_scaling.jpg" caption="Mean time between interventions during deployment. The model pretrained on 100k hours gets less correction data (1.36 h) yet improves most. (Russ Tedrake)" width="75%" %}

From this he drew an economic conclusion. Generic training data (human video, other labs' teleoperation) is becoming a commodity that anyone can buy, and stronger base models need less of it. Value therefore shifts to **on-the-job data** gathered in real deployments. He also borrowed two principles from the Toyota Production System. The first is *jidoka*: machines that stop and ask for help, which once let one worker tend 20 looms. The second is root-cause analysis of every failure, rather than only training on the correction. His current bottleneck is not AI but **manufacturing robots** in large numbers.

On academia, he said "we don't understand what we're building yet," and that there is "tons of room for deeper insights." The difficulty is whether such questions can be studied on small models or only with access to large ones. On large models, he said Walden still gets "a lot" from large-scale pretraining, though "I do believe we'll eventually throw it away." He expected large-model training to consolidate into a few well-funded players, as it has for language models. For students thinking about startups, "the bar has never been lower" to get started, but training the biggest models "costs a lot of money" and "is not for the faint of heart."

## Day 2 conclusions

1. **The center of gravity moved from demonstrations to deployment.** The discussion is now about reliability, cycle time, and learning on the job, not about collecting more demonstrations.
2. **Production metrics now exist**, reported by the companies themselves: 96% autonomous kitting, 98.6% task completion with an intervention about every 20 minutes, and a line that has never stopped. Walden already runs full shifts with remote assistance; Boston Dynamics predicts Atlas's first unassisted 8-hour shift in 2027.
3. **Industry is divided on the robot's "brain".** DeepMind expects frontier models to absorb more of robotics. Boston Dynamics and Walden found that fine-tuned, specialized models and real task data remain essential.
4. **"Bottleneck solved" claims were local.** Each one moved the problem somewhere else: data volume to data quality, compute to sim-to-real transfer, AI capability to manufacturing.
5. **Academia's role is shifting toward understanding and adaptation.** Explaining what large models do, how quickly robots can learn after deployment, how to value data, and how to handle contact and safety.

## Sources

Livestream: [Day 2](https://www.youtube.com/watch?v=uPXoJm-L3YY). Papers mentioned that are on arXiv:
[EgoScale](https://arxiv.org/abs/2602.16710) ·
[RL Token](https://arxiv.org/abs/2604.23073) ·
[FPO++ (flow policy gradients)](https://arxiv.org/abs/2602.02481) ·
[FlowDAgger](https://arxiv.org/abs/2607.08877) ·
[SuperMimic](https://arxiv.org/abs/2610.28480) ·
[Visible Touch](https://arxiv.org/abs/2609.14156) ·
[Never Too Late for Force](https://arxiv.org/abs/2607.14236) ·
[WireCraft](https://arxiv.org/abs/2606.18097) ·
[Driving, fast or slow?](https://arxiv.org/abs/2606.15251) ·
[Sequential asymmetric imitation](https://arxiv.org/abs/2606.16490) ·
[RoboNaldo](https://arxiv.org/abs/2606.11092).
Background: [π\*0.6](https://arxiv.org/abs/2511.14759) (the slower full-model RL recipe that RL Token contrasted itself with), [Gemini Robotics](https://arxiv.org/abs/2503.20020), [SONIC](https://arxiv.org/abs/2511.07820) (the 128-GPU baseline), [AgiBot World](https://arxiv.org/abs/2503.06669).
[GRAIL](https://arxiv.org/abs/2606.05160) ·
[Play2Perfect](https://arxiv.org/abs/2606.26428) ·
[DISCO](https://arxiv.org/abs/2610.25785) ·
[PACE](https://arxiv.org/abs/2610.16308) ·
[FACTR 2](https://arxiv.org/abs/2606.12406) ·
[Contact-rich VLA failures](https://arxiv.org/abs/2608.01402) ·
[SLAC](https://arxiv.org/abs/2506.04147) ·
[SafeMimic](https://arxiv.org/abs/2506.15847) ·
[DataMIL](https://arxiv.org/abs/2505.09603) ·
[GUILD](https://arxiv.org/abs/2611.05368).
Gemini Robotics 2.5 had no paper I could find.

