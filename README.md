# James
## Problem
The goal of this software is to help people with hearing disability. For these people
sometimes it can be hard to hear when somebody rings at the door, especially since most
of the doorbells are using high frequency tones.
## Solution
Everyone has a smartphone. And most the time the smartphone is nearby the owner. So this
device can be used to inform the person about somebody who ringed at the door. Since
there are many hearing aids which are connected to the smartphone to make a sound when a
push notification arrived the phone, it is the optimal way to forward the doorbell signal
to the person.

The solution of the problem could be that when somebody uses the doorbell a push notification
is sent onto the smartphone of the people with the hearing disability. For best practise
the person should use hearing aids which are connected to the smartphone.
## Technical Requirements
The project requires an app on the users device which receives the push notifications. This
app can be relatively simple, since the main job is just be installed on the phone. The
app could show the user some basic infos how to use the system. And the app needs to register
itself to the sender of the push notifications.

Then the main part of the software is the device which sends the push notifications. This
device must detect when somebody uses the doorbell button. This could either be implemented
with a relay which are between the button at the front door and the ring itself. Another
option is to install an acoustical sensor which detects when the bell rings. But in the end
it does not make any difference to the software, because in both cases there are just one pin
which is read all the time when when it is in the HIGH state, the device fires a push
notification.
## Progress
 - [x] Write down the problem
 - [x] Finding and write down a solution
 - [x] Checking the technical requirements
 - [ ] Documenting a technical solution
 - [ ] Implementing the solution in code
 - [ ] Build a prototype
 - [ ] Find somebody to test the prototype
 - [ ] Documenting problems and find solutions
 - [ ] Optimize the implementation
 - [ ] Test it again (repeat the last steps if required)
 - [ ] Build a final prototype
