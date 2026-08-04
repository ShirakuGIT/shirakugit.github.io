---
layout: post
title: "Towards a Theory of Robot Intelligence"
date: 2026-07-05
author: Shivaram Kumar Jagannathan
tags: [robotics, ideas, shower-thoughts, work-in-progress]
---

# Note: Work in progress.

I have been having these late night thoughts on what could be an interesting theory of robot intelligence.

For context, I'm a young roboticist, I've been in the field for 2 years, and I'm just breaking into research. I've worked on all sides of robotics at the fundamental level - planning for manipulation and navigation, SLAM, visual perception, controls. I've not worked heavily on whole-body control, locomotion, etc. but I think those challenges are more inherently control-theoretic rather than planning.

I'm not an expert, this article is probably just to segment my current thought process on what my observations (perception) is about regarding robotics. I've been transitioning full time into robotics for the better part of the last 3 years, ever since I found my heart doesn't lie in Software Engineering or Computer Science.

I got into robotics just when VLAs and policy fine-tuned models were taking off, but before the embodied AI concept took the world by storm. I'm a firm believer in not falling for the hype, but definitely bias my belief state towards it. 

A lot of my thought process, articles I read, lectures I watch and thoughts I have will be synthesized and put here, for my later reference, and for the world to see. 

So the purpose of this blog isn't to break any new grounds, it's generally borrowing ideas and restating many of the prevailing philosophies more succicntly. But I hope that the ideas present here encourage both me to come up with novel research and future roboticists to innovate. 

I might have vastly and wildly incorrect opinions or assumptions, but I think it's important to recognize them and have them in the first place, because what's deemed correct and incorrect today are deemed so by the observations of yesterday. If I am coompletely incorrect though, I'd love to rectify my understanding about it so feel free to email it! 

It is difficult for me to pen down all of my thoughts instantaneously, because a lot of my creative process, reasoning and thinking occurs during times of distraction. I therefore do not have a coherent stream of reasoning which I can write and call it a day. So consider this an evolving view where my perception and action continue to inform this article.

### Classical approach to intelligence 

Many foundational approaches in modern robotics achieve intelligent behavior by leveraging structured representations tailored to specific tasks or environments.

One example is **Task and Motion Planning (TAMP)**, where a robot reasons over a symbolic representation of the world described using a [planning domain definition language](https://planning.wiki/). The planning domain is expressed through abstractions such as [objects, predicates, actions, and fluents](https://www.cs.toronto.edu/~sheila/2542/w09/A1/introtopddl2.pdf), allowing high-level reasoning over sequential decision-making problems. In many ways, TAMP extends ideas from [classical AI planning](https://aiplanning-tutorial.github.io/#:~:text=AI%20Planning%20is,in%20their%20applications.) by coupling symbolic planning with geometric and motion-level constraints.

{% include figure.html src="/images/task-and-motion-planning-infographic.png" caption="Task and Motion Planning, simplified. Generated with ChatGPT." width="50%" %}

While TAMP has been highly successful for many robotic applications, its underlying abstractions also impose practical limitations. The planner reasons over a predefined symbolic model of the world, making it challenging to handle situations that fall outside the assumptions encoded in that representation. As environments become more open-ended and less structured, extending these systems to general-purpose intelligence becomes increasingly difficult.

This has contributed to a growing interest in approaches that learn representations directly from interaction and large-scale data, such as **Reinforcement Learning** and **Foundation Models**. These paradigms have demonstrated significantly stronger generalization across tasks than many hand-engineered systems. As argued in Richard Sutton's essay, [*The Bitter Lesson*](http://www.incompleteideas.net/IncIdeas/BitterLesson.html), methods that leverage computation and learning at scale have historically outperformed approaches that rely heavily on handcrafted domain knowledge.

My view is that the next step toward general robot intelligence is unlikely to come from increasingly sophisticated planners alone. Instead, it may require shifting the emphasis toward systems that first learn rich, grounded world representations through interaction, with planning emerging as one component of a broader perception–action loop.

> **TODO:** Discuss robotics capabilities that remain comparatively underexplored, such as autonomous world-model acquisition, continual adaptation, and embodied interaction.


### My theory of robot intelligence

My perspective draws heavily from **[cognitive neuroscience](https://en.wikipedia.org/wiki/Cognitive_neuroscience)** and **[evolutionary biology](https://en.wikipedia.org/wiki/Evolutionary_biology)**.

Long before sophisticated communication emerged, organisms survived by building internal models of their environment through continuous interaction. The richness of those models is curbed by an organism's embodiment—its sensory and motor capabilities. A fish understands an aquatic world far better than a terrestrial one, while humans can reason across a much broader range of environments because of their different perceptual and physical capabilities.

This is where I believe modern robotics diverges from biological intelligence.

Classical AI planning reasons over highly abstract symbolic actions using representations such as **[PDDL (Planning Domain Definition Language)](https://en.wikipedia.org/wiki/Planning_Domain_Definition_Language)**. Actions such as *pick*, *place*, *move*, and *grasp* are represented by predefined preconditions and effects. This abstraction is computationally necessary, but it strips away much of the perceptual and physical nuance that real organisms exploit while acting. When these assumptions break down because of uncertainty, **[belief state](https://en.wikipedia.org/wiki/Belief_state)** errors, **[inverse kinematics](https://en.wikipedia.org/wiki/Inverse_kinematics)** failures, or incomplete observations, planners often become brittle. The search fails not because the task is impossible, but because the available action space is fixed and incomplete.

Biological intelligence behaves differently. When an action fails, organisms rarely continue searching within the same abstract action space. Instead, they act to improve their understanding of the world. They change their viewpoint, manipulate the environment, probe uncertain objects, or gather additional sensory evidence. These actions are valuable not only because they accomplish tasks, but because they refine the organism's internal world representation.

In other words, organisms do not simply plan over a world representation—they continually construct it. Every action is simultaneously an attempt to achieve a goal and an opportunity to acquire information. As the world representation improves, new affordances, strategies, and actions become available. What initially appears to be a deadlock is often a consequence of incomplete understanding rather than an impossible problem.

This view is closely aligned with several foundational ideas in cognitive science:

{% include figure.html src="/images/intelligence-as-a-loop.png" caption="Intelligence as a loop" width="80%" %}


* **[Umwelt](https://en.wikipedia.org/wiki/Umwelt)** (Jakob von Uexküll): every organism experiences a world shaped by its sensory and motor capabilities.
* **[Affordance](https://en.wikipedia.org/wiki/Affordance)** (James J. Gibson): organisms perceive environments in terms of opportunities for action rather than static objects.
* **[Active inference](https://en.wikipedia.org/wiki/Free_energy_principle#Active_inference)** and the **[Free Energy Principle](https://en.wikipedia.org/wiki/Free_energy_principle)** (Karl Friston): perception and action form a continuous feedback loop in which agents update internal models while acting to shape future observations.

My argument is that robot intelligence should follow the same principle. Planning should not operate over a fixed symbolic representation of the world. Instead, planning, perception, and action should form a continuous **perception–action loop** in which acting improves understanding, and improved understanding expands the space of feasible actions.

Language, planning, and reasoning are therefore downstream capabilities. They should emerge from an embodied, continually evolving world representations rather than serve as its foundation.

From this perspective, the primary objective of robot learning is not to imitate behavior or generate fluent language, but to acquire robust, grounded models of the world through interaction. The quality of a robot's reasoning is ultimately determined by the quality of the world representation it constructs—and that model can only be built through the continual cycle of perception and action.


### Further Reading

The ideas in this post draw heavily from the following foundational works.

##### Jakob von Uexküll — *Umwelt*

- [Umwelt (Wikipedia)](https://en.wikipedia.org/wiki/Umwelt)
- [*A Foray into the Worlds of Animals and Humans* (1934)](https://monoskop.org/images/7/77/Uexkull_Jakob_von_A_Foray_Into_the_Worlds_of_Animals_and_Humans_with_A_Theory_of_Meaning.pdf)

##### James J. Gibson — *Affordances & Ecological Perception*

- [Affordance (Wikipedia)](https://en.wikipedia.org/wiki/Affordance)
- [*The Ecological Approach to Visual Perception* (Internet Archive)](https://archive.org/details/ecologicalapproa0000gibs)

##### Karl Friston — *Active Inference*

I personally feel when you get the time, you should really investigate deeply into all the particular topics being discussed in the Free Energy Principle Wikipedia page. 

- [Free Energy Principle (Wikipedia)](https://en.wikipedia.org/wiki/Free_energy_principle)
- [Active Inference (Wikipedia)](https://en.wikipedia.org/wiki/Free_energy_principle#Active_inference)
- [*Active Inference: The Free Energy Principle in Mind, Brain, and Behavior* (MIT Press)](https://direct.mit.edu/books/oa-monograph/5299/Active-InferenceThe-Free-Energy-Principle-in-Mind)

### Related Concepts

- [Embodied cognition](https://en.wikipedia.org/wiki/Embodied_cognition)
- [Ecological psychology](https://en.wikipedia.org/wiki/Ecological_psychology)
- [Planning Domain Definition Language (PDDL)](https://en.wikipedia.org/wiki/Planning_Domain_Definition_Language)








  
    
      
        
          
            