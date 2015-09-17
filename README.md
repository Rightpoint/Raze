
![Raze banner image](documentation/razeBanner.png)

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

Using Raze
-

Raze is designed to be used in a modular fashion with the two primary modules being UIKit and Scene. 

####UIKit 
The UIKit module is for applying effects to UIKit 
elements, see the Examples/RazeEffectDemo folder for an example of using the UIKit module.

####Scene
The scene module is for incorporating 3D objects into apps. See the Sandbox/Raze Scene Sandbox/ folder or an example of using this module. 

This module makes use of objects generated by [blender](www.blender.org) and then exported into .mesh models that Raze can read via a blender script we created: RZXBlenderModelExportIndexed.py (you can find it in the Utilities folder).




