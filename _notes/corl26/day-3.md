---
title: "CoRL 2026, Day 3: agents, world models, and the big debate"
category: conference
status: done
updated: 2026-11-14
tags: [corl, robot-learning, world-models, debate]
summary: "Frontier models enter robotics as programmers, world models as infrastructure. The closing debate asked whether imitation plus fine-tuning will yield commercially viable generalist robots. The room stayed skeptical."
---

Part of a three-day series. See the [cross-day synthesis](/notes/corl26/synthesis/) for background and definitions.

The last day had two halves with very different characters. The morning consisted of short research presentations: less opinion, more evidence about where current methods work and where they break. The afternoon moved to a concert hall for the conference's set pieces: a keynote by Fei-Fei Li on world models, a conversation between Li and AMD's chief executive Lisa Su, and a formal debate on the question underlying the whole week. **Is today's dominant recipe, imitating human demonstrations and then fine-tuning, enough to produce general-purpose robots that companies can sell at a profit?**

## Morning: frontier models as programmers

Day 1 established that frontier models are too slow to control a robot directly. Several morning talks showed where they *are* useful: **writing, testing, and repairing the code that robots run**.
- One system had language-model agents write robot programs structured as graphs of small steps (perceive, grasp, plan, check). The agents rehearsed the program in simulation and fixed it when it failed. In one example, the agents built a working simulation from a phone video in about an hour. The first real-world run exposed a physics mismatch, and the system used real video to correct both the simulation and the program.
- Another let an agent team "practice" in simulation before any task was assigned. The agents proposed their own exercises and kept the resulting code as a reusable library, which improved success on new tasks by about 20 points.
- A third constrained a language-model planner so that its plans had to obey rules covering the *whole* plan: you must open the dishwasher before loading it, and the plan must actually finish. A small 3-billion-parameter model went from 20% to 90% success on a household-planning benchmark.

**Why it matters.** This is the practical form of the "layered hybrid" that emerged across the conference. The frontier model acts as a developer and supervisor, not a controller, and physical testing remains essential.

## Morning: what still breaks

Several benchmarks were designed to isolate specific failures rather than produce one aggregate score:
- **Composition.** AtomBench taught models individual skills (picking, recognizing colors, counting), then asked them to combine these. Models that mastered every skill alone often failed when one instruction needed all three: "compositional generalization is still quite challenging even for state-of-the-art models."
- **Navigation among people.** A sidewalk-navigation benchmark found that general navigation models did much worse than models trained on sidewalk data. Nearly all struggled with pedestrians at crossings and with hand gestures such as "stop". Long routes remained "far from solved".
- **The last few meters.** In language-guided navigation, a robot that stops within the success radius but faces away from its target is still counted as a success. A metric can declare victory before the robot can actually do anything with the object.

The humanoid session showed a control stack becoming standard: a whole-body controller trained by reinforcement learning, often NVIDIA's Sonic, sitting beneath a learned high-level policy. A study of humanoid motion data concluded that "physically reliable data matters as much as data size."

## Fei-Fei Li: world models as robotics infrastructure

**Fei-Fei Li** is a Stanford professor best known for creating ImageNet, the dataset that triggered the deep-learning boom in computer vision. She now leads the startup World Labs. She framed robotics around three problems that persist "no matter what we're doing", whether or not one uses learned policies or agents:
1. The robot must **represent the state of the world**.
2. It must **predict the consequences of actions** and plan.
3. It needs **data**, and because robotics is "deeply long-tailed", that means simulating enormous numbers of situations.

A world model, she argued, addresses all three. World Labs' model, **Atlas**, moves continuously along a spectrum. Given many photos of a place, it reconstructs it accurately in 3D. Given a few, it reconstructs what it can and imagines the rest. Given only a text prompt, it generates a consistent 3D world. Its central idea is that "viewpoint is all you need": where language models predict the next word, Atlas predicts the next camera view.

{% include figure.html src="/images/notes/corl26/d3_feifei_dial.jpg" caption="A single model spanning dense 3D reconstruction (left) and pure generation from text (right). (Fei-Fei Li, World Labs)" width="75%" %}

Atlas ranked first by a wide margin on an independent benchmark of camera-controlled video generation, based on more than half a million human judgments. It also matched specialized 3D reconstruction models and now runs in real time. For robotics, World Labs is using generated worlds to train policies entirely in simulation and deploy them directly on real robots.

{% include figure.html src="/images/notes/corl26/d3_feifei_robot.jpg" caption="Robot policies trained in generated virtual worlds and deployed zero-shot on real hardware. (Fei-Fei Li, World Labs)" width="75%" %}

**Why it matters.** World models are being positioned as infrastructure that every approach needs (simulation, evaluation, and data), not as a rival to policy learning.

## Lisa Su and Fei-Fei Li on compute, models, and careers

The conversation opened with news: **AMD is acquiring World Labs**, and Li is to become AMD's chief scientist. Peter Stone of UT Austin moderated.

On the market, Su described AI as being in "the very, very early innings" and put physical AI and robotics at "hundreds of billions of dollars of opportunity over the next few years". Asked whether frontier models will simply solve robotics, the two gave complementary answers:
- **Li** called recent results "breathtaking" and expected language-model-driven robotics to "play a bigger and bigger role". But she said, "I don't think we have completely solved the System 2 problem", and that for many robotics problems "it's still unclear if we have fundamental solutions". She admitted that deciding which direction to bet on "is a little nerve-wracking", and predicted that next year's CoRL "will be very different".
- **Su** argued there is "no one model or no one direction". Frontier models will do well in some places, but specialized models will be "more cost efficient, more power efficient, and eventually perhaps a better latency" in many others.

On access to computing power, Li was blunt: "failing to resource [the] public sector is one of the biggest misses in the most important moment in history for AI." Universities, she argued, are where curiosity-driven research, the training of new researchers, and independent safety evaluation happen. Su agreed that demand for compute far exceeds supply and said reserving some of it for universities is "part of our job as an industry leader."

On careers, Li said a PhD "is not for everyone, especially in this AI age", but remains "the most protected time" for ambitious, curiosity-driven work, and that "human intelligence is still so precious." Su described her own PhD as "the best four years of my life." She urged students to develop deep intuition in a field, noting that "industry is impatient." She also rejected claims that general AI is imminent: "some of my peers [say] we're so, so close. It's just a minute away. And I actually don't believe that."

## The closing debate

The conference ended with a formal debate, moderated by Vincent Vanhoucke, on the motion:

> *The current recipe of behavior-cloning pretraining and in-domain fine-tuning will lead to commercially viable generalist robots.*

Both key terms were defined tightly. A **generalist** robot was one an end user can re-task without new training, within a well-specified domain. **Commercially viable** meant profitable on customers' money, "not on VC money." The moderator assigned the sides, so they need not reflect the speakers' personal views. In an opening show of hands, most of the audience was against the motion.

**For the motion** (Chelsea Finn of Physical Intelligence and Stanford, Pulkit Agrawal of MIT, Marc Toussaint of TU Berlin):
- *Finn* argued that commercial use depends on reliability, and that reliability has come from the same two ingredients in language, video, and coding models: large amounts of data from the target domain, and optimizing directly for success. A language model trained only on prose can write some code, but like a novice. One trained and optimized on code becomes a reliable tool. Robots, she argued, are no different.
- *Agrawal* sized a concrete target. Pick-and-place and its variants form a market of roughly $75–100 billion in North America, so 1% of it is about $1 billion in revenue. In his view, planning is "getting more and more solved" by language models. What remains is speed and reliability, which reinforcement learning has historically delivered (as with AlphaGo and coding agents) and which can be trained in simulation.
- *Toussaint* conceded the scientific point while defending the literal motion. Narrow commercial domains, like the factory deployments shown on Day 2, can be covered with enough data. "I personally would not want to do my science along that direction, but I think the proposal is true."

**Against the motion** (Leslie Kaelbling of MIT, Ed Johns of Imperial College London, Yonatan Bisk of CMU):
- *Kaelbling*, whose essay *Postmodern robotics* argues that robot data is not the key to general robots (see the [synthesis](/notes/corl26/synthesis/)), opened with "the answer's no." The "current recipe" keeps growing, now with hierarchy, reasoning, world models, and coding agents bolted on, because "AI people have this kind of disease of romanticism that makes them want to have one true trick." Language, she argued, was "exquisitely tuned for learnability" by the people who use it. The physical world was not, so covering all the situations a robot might face with human demonstrations "will never be cheap."
- *Johns* accepted that unlimited data would eventually produce a generalist, but argued that the economics fail. Real robot data costs money to collect, there was no free internet-scale supply as there was for language, and companies keep re-collecting the same data because nobody shares it. Laundry folding, he observed, is everywhere in robotics demos precisely because it is one of the few tasks worth its data cost: "the fact that there are so many robot demos folding clothes is evidence that maybe there aren't that many tasks like this."
- *Bisk* challenged the habit of borrowing arguments from language models. Imitation alone did not give them meaning, and real generality requires reasoning about situations never seen before. "The actual task for us is not to imitate."

**The exchange.** The pro side called these objections "purely academic": better research is always possible, but that was not the question. They added that simulation and reinforcement learning fit within the recipe. Kaelbling then made the key concession: "if you have a boring problem in a domain where you're not gonna endanger any people and you can collect enough data to cover the territory, then you should do BC."

The moderator raised the frontier-model question directly. General models "that have nothing to do with robotics" now score on robotics benchmarks at levels that no robotics model at the conference could match. Does that change anything?
- **Agrawal:** the field is "optimizing for the wrong metric". Customers pay for throughput (speed and reliability), and frontier models lack contact-rich experience. "I don't think a bigger, larger model is going to solve System 1."
- **Finn:** even a human barista needs about 16 hours of training before serving customers, so in-domain training is normal for skilled work.
- **Kaelbling:** the barista learns each step once by building on everything learned before. Timing matters too: "even if Astra could come up with the right answer in an hour and a half... you've missed the bus and burned your dinner."
- **Bisk:** the danger is not that frontier models "erase robotics". It is that robotics "oversimplified itself" with tidy tabletop sandboxes, and should re-test its methods under realistic conditions.

The moderator admitted that he had tried "really hard for the fight not to be about the definitions" and had "completely failed." In the closing show of hands, **"the ratios haven't moved"**. The audience stayed mostly against the motion.

**Why it matters.** The debate drew a line that matches the evidence from the factory deployments. Imitation plus fine-tuning is broadly accepted as a working recipe for **narrow, safe tasks where enough data can be collected**. It is still contested as a route to **broad generality**, and most of the room sided with the skeptics.

## Awards and what comes next

The best-paper committee chose six finalists from the 21 oral papers. **SuperMimic**, which trains a general humanoid motion controller in 3 hours on one GPU, won Best Paper. **RobotTTT**, which gives robot policies 8,000 steps of memory, won Best Student Paper. The other finalists were Play to Perfect (simulation-trained precision assembly), GRAIL (humanoid data from video generation), "What are we actually benchmarking?" (the critique of standard benchmarks), and DISCO (search-based planning distilled into a policy). The selection rewarded efficiency, memory, simulation-to-real transfer, generated data, and honest evaluation.

The organizers also announced a new year-round journal, *Transactions on Robot Learning*, whose top papers will be presented at future CoRLs. The next conference, **CoRL 2027, will be held in Paris.**

## Day 3 conclusions

1. **Frontier models are entering robotics as programmers, not controllers.** Their main roles are writing, testing, repairing, and supervising robot code and simulations.
2. **World models are being positioned as shared infrastructure.** They supply simulation, evaluation, and training data for every approach, rather than competing with policy learning.
3. **The current recipe is accepted for narrow industrial tasks and contested for broad generality.** Even its critics conceded that imitation works where tasks are safe and data can cover them. Most of the audience doubted it reaches further.
4. **Leaders in both sectors expect a mixed ecosystem and continued rapid change.** No single model is expected to win, compute access for universities is recognized as a problem, and next year's conference is expected to look different again.
