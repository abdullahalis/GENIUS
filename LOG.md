# May 06 - May 17
* Argo has been intergrated into AVP app
* Speech to text is working (still needs debugging)
    * Issues when trying to start up a second recording
* Text to speech working
* Started looking into UE5 and Unity for VR development
* Looked into building 3D mesh of protein-protein data

# May 20 - May 24
* Unity requires a pro license for visionOS development, so it has been dropped.
* UE5 was refusing to build and reported the following error:
**InvalidDataException: The archive entry was compressed using an unsupported compression method.**
Fixed it by changing 'http' to 'https' in the BaseURL in Engine/Build/Commit.gitdeps.xml [Source](https://forums.unrealengine.com/t/upcoming-disruption-of-service-impacting-unreal-engine-users-on-github/1155880/149)
* Got hand gestures working. Using hand gestures for basic commands
* Stores conversation with Argo, so we can have an on going conversation. (still needs work, continuesly mentions previous messages, even when not brought up)
* Successfully converted dot file to usdz and imported into Apple Reality Composer Pro.
* Started building interface for the string-db API

# May 27 - May 31
* Set up interface for Gecko, our protein visualization tool. We can now query the STRING-db with requests for data.
* Created functions that deal with meetings. It now transcribes, summarizes, and names them.
* Started working on functions to generate 3D models for protein data.

# June 03 - June 07
* Finished functions to create spheres for each protein returned by API request. 
* Finished tooltip-style description boxes for protein objects that appear when clicked on.

# June 10 - June 14
# June 17 - June 21
# June 24 - June 28
# July 01 - July 05
# July 08 - July 12
# July 15 - July 19
# July 22 - July 26
# July 29 - August 02