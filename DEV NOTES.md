# Code Architecture
Grimheart is an Open Source game. It is not meant to be developed with the tightest tolerances and efficiencies. The project should be accessible to brand new developers just as it is accessible to seniors.

Do not refactor what is not broken, and if you do, you must first walk a non-programmer through what you're planning on doing. If they cannot keep up, take that as a sign that your refactor is not making things better.

As much as is possible, I abstract what I can into components. Not because they should be re-used (though they often can), but because it's easier to read for newbies.

If a component is running up on 200 lines, deeply consider spliting the component into multiple parts. At 300 lines, that's a red light saying "It's too much."

# Auteur Structure & Forks
This project, Grimheart, is not design by committee or a democratic project, it is an Auteur project. Anything that goes wrong is my fault but that also means nothing gets to the final merge without my say-so.

I understand that this may be over the line for some developers, and for that reason I highly encourage and invite people who disagree with my methodology and practices to fork the project.

If you choose to fork, I will answer any questions you have about the intent of a system, but I will not leak any secrets that my own team and players are not privy to. Forks have the potential to be considered canon as long as the correct quality guidelines are met. After I leave this project to work on [Redacted], the choices of what qualifies as canon or lore will be up to the community and developers remaining. You all have my blessing.

# Stance on AI-Usage
AI is not permitted in Grimheart outside of understanding code. AI can only tell you what it has been trained on. Anything brand new or anything outside of that training is something AI simply cannot create or generate. Yes, that includes ideas. AI is no good for ideas unless you're trying to fact-check things in our real world, and even those facts need to be verified by hand.

Grimheart is not a newborn game that is absent of influence, but it is original and bizarre with fresh and innovative ideas. The goals and philosophy of Grimheart's development are incompatible with the incentives provided by AI.

We aren't shipping a B2B corpo-slop product, we are crafting an experience. If you don't respect the craft, then fork or get lost.

# Add-Ons Explained
### Terrain3D
Terrain3D is the logical choice for Terrain Sculpting, Clipmaps, and large world sizes on limited hardware.

### OWDB
OWDB is the World Streaming solution. Within a radius, the world, enemies, and AI are processed. Outside of the bubble, they are either static/hibernating or processing on a very low and barebones level.
# Bugs


# TODO
