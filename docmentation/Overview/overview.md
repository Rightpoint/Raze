
Raze : A supplemental graphics engine for apps
=

Why Raze?
-
####Designed for apps
Raze is designed from the ground up to provide a way for developers to add customized hardware accelerated graphics and effects to their applications. While other APIs exist for mobile accelerated graphics, they typically assume that the developer is going to be using that API as the app's core functionality: for example, when making a game. In contrast, Raze is designed to provide similar functionality to commercial graphics engine, but is built around the concept that the Raze engine is likely *not* going to be the app's primary method of displaying the user interface: in nearly all cases this will be done via Apple's UIKit. This means that Raze must have little to no impact on an existing app architecture when it is dropped in, it should only use CPU and GPU processing when it is active, and after it is used by an app it should leave no trace of its use in memory. 

####Open source 
 Frequently when using existing graphics APIs developers will encounter cases where the API does not function as desired, this is often not necessarily due to bugs in the API, but rather a lack of the developer's ability to fully understand the API due to the black box nature of proprietary code. By making Raze open source we will be allowing users full access to the API's code. This also would allow us to continue to develop and extend Raze based upon community feedback.
 
####Minimal  Footprint
As part of being designed for Apps, Raze is designed from the ground up to be modular in nature. The code base is divided up into a set of frameworks (e.g. Core, UIKit, Scene, Animations). As Raze develops we will continue with this modular approach so that users of the API will be able to take only what they need from the API.
 

Internal Justification
-
At Raizlabs, those of us who are familiar with openGL have pushed for its use more extensively in our applications. However,  the problem with the use of openGL in apps is that 1) it can be intrusive (either it does not appear to fit with the rest of the app or it requires too much in the way of resources to make it worth using) 2) it is difficult to maintain (only someone who has specialized knowledge can debug and extend the code). Raze is designed to address both of these issues.

####Extending Design 
Not only is the API designed to play nicely with UIKit as described above, we want the API to specialize in effects that would not be jarring within most iOS applications.  To that end, as we develop Raze we are looking to our designers and asking them: "what would you like to do that is currently difficult for developers to pull off?", and "how can we take design in new directions?".  One example of this is we have discussed taking material design and extending it to have materials behave even more like materials by introducing effects that enable folding, bending, and tearing. 

####Free polish
The additional benefit of having Raze be an active hack project at Raizlabs is that other products can utilize the Raze team to work on special effects for a given app without having to add developer resources. For the Raze team, this will only improve the engine by testing it in production apps and adding to its library of effects and capabilities. 

####Internal training
The extensive documentation of Raze is also designed to allow Raizlabs developers to keep up to speed on making use of accelerated graphics within a modular, flexible architecture. We hope to continue to push Raze to incoporate the latest technologies including moving to having the majority of the code base be in Swift, using Apple's Metal and eventually including a GPU computation module. 