---
title: "CoRL 2026, Day 3: agents, world models, and the big debate"
category: conference
status: done
updated: 2026-11-14
tags: [corl, robot-learning, world-models, debate]
summary: "Frontier models enter robotics as programmers, world models as infrastructure. The closing debate asked whether imitation plus fine-tuning will yield commercially viable generalist robots. The room seemed skeptical, though no votes were counted."
---

Part of a three-day series. See the [cross-day synthesis](/notes/corl26/synthesis/) for background and definitions.

The last day had two halves with very different characters. The morning consisted of short research presentations: less opinion, more evidence about where current methods work and where they break. The afternoon moved to a concert hall for the conference's set pieces: a keynote by Fei-Fei Li on world models, a conversation between Li and AMD's chief executive Lisa Su, and a formal debate on the question underlying the whole week. **Is today's dominant recipe, imitating human demonstrations and then fine-tuning, enough to produce general-purpose robots that companies can sell at a profit?**

## Morning: frontier models as programmers

Day 1 established that frontier models are too slow to control a robot directly. Several morning talks showed where they *are* useful: **writing, testing, and repairing the code that robots run**.
- One system had language-model agents write robot programs structured as graphs of small steps (perceive, grasp, plan, check). The agents rehearsed the program in simulation and fixed it when it failed. In one example, the agents built a working simulation from a phone video in about an hour. The first real-world run exposed a physics mismatch, and the system used real video to correct both the simulation and the program.
- Another let an agent team "practice" in simulation before any task was assigned. The agents proposed their own exercises and kept the resulting code as a reusable library, which improved success on new tasks by about 20 points.
- A third constrained a language-model planner so that its plans had to obey rules covering the *whole* plan: you must open the dishwasher before loading it, and the plan must actually finish. A small 3-billion-parameter model went from 20% to 90% success on a household-planning benchmark, and an open 20-billion-parameter model scored "above every frontier model" on it. On a narrow, rule-heavy task, structure beat scale.

**Why it matters.** This is the practical form of the "layered hybrid" that emerged across the conference. The frontier model acts as a developer and supervisor, not a controller, and physical testing remains essential.

## Morning: what still breaks

Several benchmarks were designed to isolate specific failures rather than produce one aggregate score:
- **Composition.** AtomBench tested individual skills (picking, pouring, recognizing colors, counting) separately, then asked models to combine them. Even the single skills were weak: the best model managed 46% on motor skills, and averages for pouring (20%) and reaching into containers (9%) were low. Combinations did worse still, even when a model could do each part alone. The slide's takeaway: "learning atomic skills does not guarantee compositional generalization."
- **Navigation among people.** A sidewalk-navigation benchmark, using simulated pedestrians, found that general navigation models did much worse than models trained on sidewalk data. Nearly all struggled with pedestrians at crossings and with hand gestures such as "stop". Long routes remained "far from solved".
- **The last few meters.** In language-guided navigation, a robot that stops within the success radius but faces away from its target is still counted as a success. A metric can declare victory before the robot can actually do anything with the object.

The humanoid session showed a common control stack: a whole-body controller trained by reinforcement learning, often NVIDIA's Sonic, sitting beneath a learned high-level policy. It's common, not yet a settled standard. A study of humanoid motion data concluded that "physically reliable data matters as much as data size."

Classical methods also held their ground. The morning opened with a GPU optimization toolkit that solved 2,000 inverse-kinematics problems in 70 milliseconds, and argued that optimization is still the right tool for kinematics and motion planning. The RAI Institute used a planner too slow to run on the robot as a *data generator* for reinforcement learning. And a sensor-simulation paper pointed out that simulators share "a critical blind spot": "they do not simulate how robots actually see the world."

## Fei-Fei Li: world models as robotics infrastructure

**Fei-Fei Li** is a Stanford professor best known for creating ImageNet, the dataset that triggered the deep-learning boom in computer vision. She now leads the startup World Labs. She framed robotics around three problems that persist "no matter what we're doing", whether or not one uses learned policies or agents:
1. The robot must **represent the state of the world**.
2. It must **predict the consequences of actions** and plan.
3. It needs **data**, and because robotics is "deeply long-tailed", that means simulating enormous numbers of situations.

A world model, she argued, addresses all three. World Labs' model, **Atlas**, moves continuously along a spectrum. Given many photos of a place, it reconstructs it accurately in 3D. Given a few, it reconstructs what it can and imagines the rest. Given only a text prompt, it generates a consistent 3D world. Its central idea is that "viewpoint is all you need": where language models predict the next word, Atlas predicts the next camera view.

{% include figure.html src="/images/notes/corl26/d3_feifei_dial.jpg" caption="A single model spanning dense 3D reconstruction (left) and pure generation from text (right). (Fei-Fei Li, World Labs)" width="75%" %}

Atlas ranked first by a wide margin on an independent benchmark of camera-controlled video generation, based on more than half a million human judgments, results Li said she had received "a few days ago". It also matched specialized 3D reconstruction models and now runs in real time. Her own example showed the limits. Given two photos of Stanford's Main Quad, it produced a plausible quad, but "not our main quad". Given eight, it left out the Memorial Church, because the church wasn't in any of the photos. A plausible world is not a faithful reconstruction, and neither guarantees physics accurate enough to train robots. For robotics, World Labs is using generated worlds to train policies entirely in simulation and deploy them directly on real robots.

{% include figure.html src="/images/notes/corl26/d3_feifei_robot.jpg" caption="Robot policies trained in generated virtual worlds and deployed zero-shot on real hardware. (Fei-Fei Li, World Labs)" width="75%" %}

**Why it matters.** World models are being positioned as infrastructure that every approach needs (simulation, evaluation, and data), not as a rival to policy learning.

## Lisa Su and Fei-Fei Li on compute, models, and careers

The conversation opened with news, as described on stage: an **AMD acquisition of World Labs is "in process"**, and Li was introduced as AMD's incoming chief scientist. Peter Stone of UT Austin moderated.

On the market, Su described AI as being in "the very, very early innings" and put physical AI and robotics at "hundreds of billions of dollars of opportunity over the next few years". Asked whether frontier models will simply solve robotics, the two gave complementary answers:
- **Li** called recent results "breathtaking" and expected language-model-driven robotics to "play a bigger and bigger role". But she said, "I don't think we have completely solved the System 2 problem", and that for many robotics problems "it's still unclear if we have fundamental solutions". She admitted that deciding which direction to bet on "is a little nerve-wracking", and predicted that next year's CoRL "will be very different".
- **Su** argued there is "no one model or no one direction". Frontier models will do well in some places, but specialized models will be "more cost efficient, more power efficient, and eventually perhaps a better latency" in many others.

On access to computing power, Li was blunt: "failing to resource [the] public sector is one of the biggest misses in the most important moment in history for AI." Universities, she argued, are where curiosity-driven research, the training of new researchers, and independent safety evaluation happen. Su agreed that demand for compute far exceeds supply and said reserving some of it for universities is "part of our job as an industry leader."

On careers, Li said a PhD "is not for everyone, especially in this AI age", but remains "the most protected time" for ambitious, curiosity-driven work, and that "human intelligence is still so precious." Su described her own PhD as "the best four years of my life." She urged students to develop deep intuition in a field, noting that "industry is impatient." She also rejected claims that general AI is imminent: "some of my peers [say] we're so, so close. It's just a minute away. And I actually don't believe that." When Stone pointed to the brain's efficiency as a research direction, Li warned against comparing "the 20 watts in our brain" with the energy needed to train a model, because "evolution is expensive". Su's parting advice: "be very ambitious and very optimistic... you are in the best possible time."

## The closing debate

The conference ended with a formal debate, moderated by Vincent Vanhoucke, on the motion:

> *The current recipe of behavior-cloning pretraining and in-domain fine-tuning will lead to commercially viable generalist robots.*

Both key terms were defined tightly. A **generalist** robot was one an end user can re-task without new training, within a well-specified domain. **Commercially viable** meant profitable on customers' money, "not on VC money." The moderator assigned the sides, so they need not reflect the speakers' personal views. In an informal opening show of hands, the room leaned against the motion. (The transcript of this session has no speaker labels; who-said-what below is inferred from the moderator's hand-offs and the panelists naming each other.)

**For the motion** (Chelsea Finn of Physical Intelligence and Stanford, Pulkit Agrawal of MIT and a robotics company whose name the captions garbled, Marc Toussaint of TU Berlin):
- *Finn* argued that commercial use depends on reliability, and that reliability has come from the same two ingredients in language, video, and coding models: large amounts of data from the target domain, and optimizing directly for success. A language model trained only on prose can write some code, but like a novice. One trained and optimized on code becomes a reliable tool. Robots, she argued, are no different.
- *Agrawal* sized a concrete target. Pick-and-place and its variants form a market of roughly $75–100 billion in North America, so 1% of it is about $1 billion in revenue. In his view, planning is "getting more and more solved" by language models. What remains is speed and reliability, which reinforcement learning has historically delivered (as with AlphaGo and coding agents) and which can be trained in simulation.
- *Toussaint* conceded the scientific point while defending the literal motion. Narrow commercial domains, like the factory deployments shown on Day 2, can be covered with enough data. "I personally would not want to do my science along that direction, but I think the proposal is true."

**Against the motion** (Leslie Kaelbling of MIT, Ed Johns of Imperial College London and a company the captions garbled, Yonatan Bisk of CMU):
- *Kaelbling*, whose essay *Postmodern robotics* argues that robot data is not the key to general robots (see the [synthesis](/notes/corl26/synthesis/)), opened with "the answer's no," after naming "the question that's probably burning a lot of you": "what is the future of human engineers and researchers? I don't know. It's burning me." She added that commercial robots also have to "not cause too many lawsuits." The "current recipe" keeps growing, now with hierarchy, reasoning, world models, and coding agents bolted on, because "AI people have this kind of disease of romanticism that makes them want to have one true trick." Language, she argued, was "exquisitely tuned for learnability" by the people who use it. The physical world was not, so covering all the situations a robot might face with human demonstrations "will never be cheap." Models of the world, she argued, can be learned piece by piece with less data than policies can.
- *Johns* accepted that unlimited data would eventually produce a generalist, but argued that the economics fail. Real robot data costs money to collect, there was no free internet-scale supply as there was for language, and companies keep re-collecting the same data because nobody shares it. Laundry folding, he observed, is everywhere in robotics demos precisely because it is one of the few tasks worth its data cost: "the fact that there are so many robot demos folding clothes is evidence that maybe there aren't that many tasks like this."
- *Bisk* challenged the habit of borrowing arguments from language models. Imitation alone did not give them meaning, and real generality requires reasoning about situations never seen before. "The actual task for us is not to imitate." Robotics, he argued, could be "the forefront of what it would mean to study intelligence."

**The exchange.** The pro side called these objections "purely academic": better research is always possible, but that was not the question. They added that simulation and reinforcement learning fit within the recipe. Kaelbling then made the key concession, after joking that "everybody should pay 10% back to the [ivory] tower": "if you have a boring problem in a domain where you're not gonna endanger any people and you can collect enough data to cover the territory, then you should do BC." Johns answered that if success comes through simulation rather than paying for task data, "then you're on our side."

The moderator raised the frontier-model question directly. General models "that have nothing to do with robotics" now score on robotics benchmarks at levels that no robotics model at the conference could match. Does that change anything?
- **Agrawal:** the field is "optimizing for the wrong metric". Customers pay for throughput (speed and reliability), and frontier models lack contact-rich experience. "I don't think a bigger, larger model is going to solve System 1." A model "like Mythos or Astra" (a model name heard only in the audio), made bigger, would not solve all of robotics.
- **Finn:** even a human barista needs about 16 hours of training before serving customers, so in-domain training is normal for skilled work.
- **Kaelbling:** the barista learns each step once by building on everything learned before. Timing matters too: "even if Astra could come up with the right answer in an hour and a half... you've missed the bus and burned your dinner."
- **Bisk:** the danger is not that frontier models "erase robotics". It is that robotics "oversimplified itself" with tidy tabletop sandboxes, and should re-test its methods under realistic conditions.
- **Johns:** teaching robots on the job is good, but a zero-shot robot arising "just through very narrow, task-specific data collection is probably unlikely to emerge."

The moderator admitted that he had tried "really hard for the fight not to be about the definitions" and had "completely failed." In the closing show of hands, the moderator said the ratios "haven't moved quite too much... as far as I can tell." No counts were taken, so treat that as an impression of the room, not a result.

**Why it matters.** The debate drew a line that matches the evidence from the factory deployments. Even the skeptics allowed that imitation plus fine-tuning works for **narrow, safe tasks where enough data can be collected**. It is still contested as a route to **broad generality**.

## Awards and what comes next

The best-paper committee chose six finalists from the 21 oral papers. **SuperMimic**, which trains a general humanoid motion controller in 3 hours on one GPU, won Best Paper. **RobotTTT**, which gives robot policies 8,000 steps of memory, won Best Student Paper. The other finalists were Play to Perfect (simulation-trained precision assembly), GRAIL (humanoid data from video generation), "What are we actually benchmarking?" (the critique of standard benchmarks), and DISCO (search-based planning distilled into a policy). The selection rewarded efficiency, memory, simulation-to-real transfer, generated data, and honest evaluation.

The organizers also announced a new year-round journal, *Transactions on Robot Learning*, whose top papers will be presented at future CoRLs, which answers Burgard's Day 1 call to publish shared work in journals. They also announced a Test of Time award for CoRL papers, starting next year. After a run of projector failures, the general chair joked that "debugging PowerPoints on stage with my advisor" showed "how hard it is to do robotics in the real world."

The closing remarks for the Robot Learning Foundation (the speaker was introduced only as "Ken") were the bluntest summary of the week. He said the audience vote had surprised him, and that robotics is in "what I would call a revenue crisis": the field needs to start earning money, which depends on reliability, throughput, and interpretability, since industry is "not comfortable with the black box." He was "very optimistic", though: "I don't think it's a crisis in the sense that it's going away. I think it's just changing."

The next conference, **CoRL 2027, will be held in Paris.**

## Day 3 conclusions

1. **Frontier models are entering robotics as programmers, not controllers.** Their main roles are writing, testing, repairing, and supervising robot code and simulations.
2. **World models are being positioned as shared infrastructure.** They supply simulation, evaluation, and training data for every approach, rather than competing with policy learning.
3. **The current recipe is accepted for narrow industrial tasks and contested for broad generality.** Even its critics conceded that imitation works where tasks are safe and data can cover them. The room seemed to doubt it reaches further, but no votes were counted.
4. **Leaders in both sectors expect a mixed ecosystem and continued rapid change.** No single model is expected to win, compute access for universities is recognized as a problem, and the field's near-term test is commercial: reliability, throughput, revenue.

## Sources

Livestreams: [Day 3 morning](https://www.youtube.com/watch?v=bYUBR0OcK_c), [Day 3 afternoon](https://www.youtube.com/watch?v=vzyHMAlvglU). The afternoon had no captions and was transcribed locally, so quotes may contain small errors and speaker names are inferred. Papers mentioned that are on arXiv:
[SidewalkBench](https://arxiv.org/abs/2606.16953) ·
[PHUMA](https://arxiv.org/abs/2510.26236) ·
[OpenHLM](https://arxiv.org/abs/2606.22174) ·
[VisionSIM](https://arxiv.org/abs/2611.08368) ·
[Kamino (Disney)](https://arxiv.org/abs/2603.16536) ·
[LadderMan](https://arxiv.org/abs/2606.05873) ·
[Intent disambiguation](https://arxiv.org/abs/2609.34270) ·
[SuperMimic](https://arxiv.org/abs/2610.28480) ·
[What are we actually benchmarking?](https://arxiv.org/abs/2606.04233).
AtomBench has a [project page](https://flageval-baai.github.io/AtomBenchPage/). Graph-as-Policy, RATS, MetaControl, RobotTTT, and World Labs' Atlas had no arXiv record I could find.

