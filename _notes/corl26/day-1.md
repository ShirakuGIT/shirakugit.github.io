---
title: "CoRL 2026, Day 1: absorbing the frontier model"
category: conference
status: done
updated: 2026-11-14
tags: [corl, robot-learning, foundation-models, benchmarks]
summary: "A general frontier model now outperforms robot foundation models in simulation. Day 1 asked what that leaves for robotics, and answered with time, contact, and measurement."
---

Part of a three-day series. Start with the [cross-day synthesis](/notes/corl26/synthesis/) for background and definitions of the terms used here.

Day 1 opened in the shadow of **GPT-6 Astra**, a general-purpose frontier model released two months earlier. It was not designed for robots, yet when connected directly to simulated robots it completed far more tasks than purpose-built robot foundation models. The day's talks kept returning to one question: if a general model can already plan and act, what is left for robot learning? The answers clustered around three ideas. Physical control runs against a clock that slow models cannot meet. Contact and force are still poorly handled. And the benchmarks the field uses to measure progress can hide the failures that matter.

## Frontier reasoning meets the physical clock

The keynote that framed the day came from **Hang Zhao**, who leads a robotics lab at Tsinghua University and co-founded the robotics company Galaxea AI. He started by acknowledging Astra's results, telling the audience that "many of us in this community are not ready for this." He then pointed out what the benchmarks left out: **time**. Each call to Astra took about 18 seconds, and the simulated robot spent 97% of each episode standing still while the model thought. Simulation benchmarks normally pause the world while the model computes, which hides this cost.

To make the point concrete, Zhao tested five ways of connecting a frontier model to a robot in a simulated kitchen. They ranged from having the model write a program once, to calling it at every step, to letting it orchestrate a library of small, fast learned skills. With the clock paused, all but the simplest scored above 60%. With a real 50-second deadline, the approaches that called the model at every step collapsed to 15–20%. Orchestration, where the slow model decides *what* to do and fast skills decide *how*, held at 65%.

{% include figure.html src="/images/notes/corl26/d1_zhao_wallclock.jpg" caption="Success rates with the clock paused (grey) and running (orange). Approaches that consult the frontier model at every step collapse when time is real. (Hang Zhao)" width="80%" %}

He also mapped jobs onto the layers. A fixed assembly line needs only System 0. Parcel sorting needs a strong System 1. Housework needs a strong System 2 but can tolerate a slower System 1. And his group's latest fast world-action model runs at 60 milliseconds per action on a single gaming GPU.

From this he argued that robot systems should be divided **by reaction time rather than by function**. The traditional split is perception, planning, and control. His proposal is System 2 (a frontier model, reasoning over seconds to minutes), System 1 (a learned policy reacting to the hand and object at tens of decisions per second), and System 0 (a controller managing contact and balance hundreds of times per second). A slipping cup, in this view, is a System 0 problem: perception and correction both have to happen within milliseconds, so they cannot be split across layers.

His most useful observation concerned the connections between layers. Higher layers already pass rich instructions downward: language, goals, programs. Very little flows back up. A lower layer rarely reports that force has changed, that an object is slipping, or that it is unsure. His example was a humanoid following a "lift the box" command while the box slid out of its hands, with "no way to tell anyone."

{% include figure.html src="/images/notes/corl26/d1_zhao_feedback.jpg" caption="Instructions flow down the stack; feedback about contact, progress, and confidence mostly does not flow back up. (Hang Zhao)" width="80%" %}

Asked whether System 2 research was now finished, Zhao largely agreed: "it's a good news that system 2 are largely solved by the frontier models." He then added that these models "are not really designed for robotics", being weak at spatial reasoning and at closing the loop on a physical task. There is "still space to explore for system two," he said, but more opportunity in System 1 and System 0, and suggested a physical split of compute: System 2 in the cloud, System 1 on a server shared by robots in a factory or store, and System 0 on the robot itself.

**Why it matters.** This talk set the terms for the rest of the conference. It accepted frontier models as a genuine capability while arguing that they occupy only the slowest layer of a robot. The open research moved to the fast layers and to the feedback between them.

## Generalist policies: what helps them generalize

The first research session examined **generalist policies**: single models trained on many tasks and robots, in the hope that they can combine skills in new ways. The hope is modeled on image generators, which could draw an "avocado armchair" without ever having seen one by combining "avocado" and "armchair."

**Physical Intelligence**, a startup building robot foundation models, presented the most concrete result. Real robot datasets always mix good demonstrations with clumsy ones. Naively adding more low-quality data made their laundry-folding model *worse*, because the model learned to imitate the average. When each demonstration was labeled with information about its quality, adding more data made the model *better*, because the model could then be asked for the high-quality behavior. They also showed a model folding shirts on a robot arm for which no folding data had ever been collected, by combining folding knowledge from one robot with movement knowledge from another. They were candid that quality labels are still assigned by hand, and called measuring data quality "an active area of research."

Two other talks addressed what policies should remember. Most current robot policies decide from a single camera frame and have no memory. In one example, a policy cooking a grilled cheese had no notion of elapsed time and would leave it on the pan indefinitely. Adding compressed short-term video and running text summaries let a policy work on 15-minute tasks and even change strategy after a mistake. A Stanford and NVIDIA team argued that **context length** should become a scaling axis for robots, as it has for language models. Their model used 8,000 steps of history at constant speed, and its performance rose steadily as context grew.

Several shorter talks showed how fragile generalization still is:
- Policies often **ignore the instruction** and repeat a well-practiced task whenever the scene contains its familiar objects. On one standard benchmark they score highly even with the language input removed.
- A [Berkeley study](https://arxiv.org/abs/2607.29687) found that robots don't need to practice every combination of skills (a quarter of the combinations was enough). When they did fail on a new combination, the training data already contained every motion needed, and a single demonstration per task fixed it. So the problem was picking the right skill from the instruction, not missing motor skill.
- A study of **cross-robot transfer** showed that adding just 5% of data from the target robot to pretraining raised one robot's success from 51 to 69. Papers use "zero-shot" for both settings, so their numbers often can't be compared.

**Why it matters.** Scaling generalist models works best when the model is told what good behavior looks like, and combining skills is possible but fragile. Researchers claiming generalization need to state precisely what the model saw during training.

## World models and simulation as data sources

A **world model** predicts what the world will look like after the robot acts. Three uses appeared on Day 1:
- **As a policy.** NVIDIA's DreamZero fine-tuned a large video-generation model to predict future frames and actions together. Without task-specific training, it solved tasks such as untying shoelaces better than standard robot models, after its inference was sped up from 5.7 seconds to 0.15 seconds per step.
- **As an evaluator.** Testing a policy inside a world model is far cheaper than running real robots. Giving the model a spatial memory, so objects did not change shape when they went out of view, raised the agreement between imagined and real success rates to 0.97.
- **As an attack surface.** One study showed that subtly altered images in third-party training data could make a world model generate harmful behaviors that a policy would then learn. This is an early warning that the data supply chain for robots needs security.

On simulation, the Allen Institute for AI trained policies **entirely on synthetic data**: 1.7 million simulated demonstrations across 94,000 generated environments, with everything randomized that could be. The policies transferred to real robots for pick-and-place with no real data at all. The authors noted that deformable objects such as cloth are not yet supported.

**Why it matters.** Generated data, from video models or physics simulators, is becoming a serious alternative to collecting robot data by hand, at least for rigid objects.

## The benchmarking problem

One of the most discussed talks came from the Toyota Technological Institute at Chicago, under the title **"What are we actually benchmarking?"** A shared benchmark lets labs compare methods, but once everyone optimizes for it, it quietly becomes the field's definition of progress. The team showed four ways a high score can mislead:
1. **Shortcuts.** A tiny model with no robot pretraining, which treats each instruction as an arbitrary ID rather than reading it, scored 97.6 on LIBERO. A high LIBERO score is widely read as evidence of large-scale pretraining and language understanding.
2. **Noise.** Few reported improvements on standard benchmarks are statistically significant given the number of trials run.
3. **Narrow tests.** Moving test objects slightly, within the range seen in training, lowered every policy's score.
4. **Data advantages.** A small model given extra simulated training data matched the best reported result, so the score cannot separate genuine generalization from better data.

{% include figure.html src="/images/notes/corl26/d1_bench_shortcut.jpg" caption="A 0.09-billion-parameter model with no robot pretraining nearly matches the best large models on a standard benchmark." width="80%" %}

The root cause, the presenters argued, is a public, fixed, narrow test set. Asked which benchmarks are most at risk, they answered that now that frontier models can "practice on" any public benchmark without retraining, all of them are.

A sponsor initiative, **Robot Colosseum**, answered with scale. Hundreds of robots were evaluated more than 21,000 times in real homes, factories, and cafés. No model was best everywhere, general frontier agents could rival specialized robot models (according to their slide), no humanoid model reached full success, and about 400–500 head-to-head comparisons were needed before differences became statistically meaningful. The organizers offered 10,000 hours of free evaluation to academic labs.

**Why it matters.** The field's most-used scoreboards can overstate real capability. Results should be read with that in mind, and the talks argued for adding hidden, more diverse, or real-world evaluation.

## Speed as a research topic

A whole spotlight session was given over to making policies faster or cheaper to run, which is academic support for Zhao's point about time:
- [BitVLA](https://arxiv.org/abs/2506.07530) shrank a robot model's weights to three values (-1, 0, +1). It used 11 times less memory and ran 4.4 times faster than a comparable open model.
- One system split a model between the cloud and the robot by predicting what the cloud part would compute, raising the control rate almost tenfold.
- A policy that decides for itself when to replan, instead of replanning on a fixed schedule, saved about 38% of the model calls at the same success rate.
- A model-based method that plans in chunks ran 30 times faster at inference than a standard baseline.

## Industry's answer: "everything is a skill"

**Jim Fan**, who leads robotics research at NVIDIA, gave the day's most memorable industry talk. He described the community's reaction to Astra as five stages of grief: denial ("cherry-picked"), anger, bargaining ("they still need my motion planner, right?"), depression ("my PhD is now a joke in the system prompt"), and acceptance ("winter is coming"). Then he added a sixth stage, **celebration**. His argument was that "you can't possibly be excited about a System 1 for language models and hold a funeral for robotics." A fast, reactive layer is exactly what robots need and what frontier models lack.

{% include figure.html src="/images/notes/corl26/d1_jimfan_grief.jpg" caption="The community's reaction to Astra: five stages of grief, followed by celebration. (Jim Fan, NVIDIA)" width="80%" %}

NVIDIA's approach pairs Astra with GR00T 2, its own 2-billion-parameter model that predicts future frames and actions together. GR00T learns from "easy" data: grippers worn by people, motion-capture gloves, an exoskeleton that maps one-to-one onto a robot hand, and simulation. Astra contributes in three ways. It can draw guidance directly onto the camera image for GR00T to follow, monitor execution and correct the action only when needed, or write and test code skills in simulation that the robot can call on. He showed an assembly cell running overnight at "essentially 100% robustness", a self-reported figure with no stated test protocol. As Fan put it, "neither Astra nor GR00T can do this alone." His case for local models was blunt: "You need to own System 1, untethered."

His conclusion was that Astra "didn't shatter our dreams, but it shattered our walled gardens." Frontier models lower the barrier to entry, so robotics "is no longer an elitist sport." NVIDIA announced open releases of its model weights, simulator, agent framework, annotation models, 100,000 hours of human video, and hardware designs.

Other industry voices reinforced the picture. GM described driving policies trained by **self-play** in a simulator running more than 50,000 times faster than real time, combined with imitation of human driving, and targets an "eyes-off" highway product for 2028. It also uses vision-language models in the car to reason about unusual scenes, such as a crash site with police cars, and offline to mine and triage driving data. Several companies now sell **egocentric human video** by the million hours. One company's promotional video stated flatly that "teleop data is not scalable at all."

**Why it matters.** NVIDIA's version of the working architecture is a frontier model as supervisor and planner, with a fast, locally owned model doing the physical work. Other companies drew the boundaries differently. Open releases are now part of how companies compete.

## The academic keynotes: interaction, touch, and the boulder

**Negar Mehr** (UC Berkeley) argued that interaction between multiple agents is a distinct problem that more data will not solve. When two robots carry an object together, one robot's small deviation from its demonstrations can doom the whole task. The data needed to cover such cases grows exponentially with the number of agents. Her group's most promising results used foundation models as **coaches**: breaking tasks into steps, writing reward functions, and judging which agent deserved credit for a team outcome. These coaches outperformed standard multi-agent learning methods by a wide margin, even with the weaker models available in 2025.

**Wolfram Burgard** (University of Technology Nuremberg), a pioneer of probabilistic robotics, framed the field's history through the myth of **Sisyphus**, condemned to push a boulder uphill only to watch it roll back. Robotics has pushed three times: probabilistic methods in the 1990s, deep learning in the 2010s, and foundation models now. Each time the community believed the boulder would reach the top. He believes foundation models are a genuine step, and said that building the AI is "mostly underestimated by investors ... and even politicians". He listed what they still miss:
- Precision. Classical methods localize a robot on a factory floor to about a millimeter. "Who believes that this can be achieved with foundation models as well? Nobody... maybe in a few years." He put manipulation at "level three, maybe a few level four" on a self-driving-style autonomy scale.
- Calibrated uncertainty: knowing how confident a learned perception system really is, which classical estimation depends on.
- The ability to handle messy, unstructured homes, which is why factories will be automated much sooner.
- **Touch and force.** "There are many people in the world who don't have vision and still live a decent life. But there's very few people in the world who don't have tactile information." This, he argued, is where robotics can distinguish itself from computer vision.
- Navigation. He was surprised "so few people" at the conference work on it.

He also voiced unease about growing public skepticism toward AI, and closed with a call for academia to pool resources in **"a CERN of robotics"** to stay relevant next to large industrial teams. University compute isn't uniformly scarce, though. His Bavarian center was receiving "an additional number of thousand GB200 GPUs", and in the opening, Peter Stone said UT Austin's new computing school has "the most GPUs of any computing group" in the US.

{% include figure.html src="/images/notes/corl26/d1_burgard_cern.jpg" caption="Burgard's closing call: shared infrastructure and a jointly built robotics foundation model. (Wolfram Burgard)" width="70%" %}

## Day 1 conclusions

1. **In Zhao's timed tests, frontier models worked as slow planners, not controllers.** They handle task-level reasoning well but are too slow for physical control. Response time is now a design constraint, and a research area, in its own right.
2. **Industry is building beneath and around frontier models.** Companies on stage were investing in fast local models, cheap data sources, and open software stacks.
3. **Academia's advantage lies in rigor and in problems that do not scale away.** Valid evaluation, calibrated uncertainty, touch and force, multi-agent interaction, and continual learning all resist being solved by more data alone.
4. **The data question is open.** No Day 1 speaker argued that teleoperation alone would scale. Human video, simulation, and generated data are the contenders.

## Sources

Livestream: [Day 1](https://www.youtube.com/watch?v=F_4AAOQsWlA). Papers mentioned that are on arXiv:
[DreamZero](https://arxiv.org/abs/2602.15922) ·
[MolmoBot](https://arxiv.org/abs/2603.16861) ·
[What are we actually benchmarking?](https://arxiv.org/abs/2606.04233) ·
[MEM (memory)](https://arxiv.org/abs/2603.03596) ·
[Being-H0.5](https://arxiv.org/abs/2601.12993) ·
[When vision overrides language](https://arxiv.org/abs/2602.17659) ·
[Diagnosing compositional generalization](https://arxiv.org/abs/2607.29687) ·
[BitVLA](https://arxiv.org/abs/2506.07530) ·
[Robust autonomy emerges from self-play](https://arxiv.org/abs/2502.03349) (cited by GM).
Physical Intelligence's π0.7, RobotTTT, MemWorld, Robot Colosseum, and GR00T 2 had no arXiv record I could find.

