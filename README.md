# CleanBucket

**CleanBucket** is an innovative app where users can record themselves recycling in a fun, engaging way and share their efforts with a community. People can scroll through videos, rate them, and get inspired by others to make recycling more exciting and impactful.

## Table of Contents
- [Inspiration](#inspiration)
- [What It Does](#what-it-does)
- [How It Works](#how-it-works)
- [Challenges](#challenges)
- [Accomplishments](#accomplishments)
- [What We Learned](#what-we-learned)
- [What's Next](#whats-next)

## Inspiration

The idea for **CleanBucket** emerged from a desire to make recycling more fun and interactive. Recycling can feel like a chore for many, so we wanted to change that by making it more engaging. By combining social media elements with sustainability, we envisioned a platform where people could creatively showcase their recycling efforts and inspire others—similar to the popularity of short-form content on social media. The ultimate goal is to motivate more people to recycle by making it social, fun, and rewarding.

## What It Does

**CleanBucket** allows users to post videos of their recycling activities, from showing off impressive trickshots to just having fun with the process. The app includes a rating system to add a competitive edge where users can interact with others' videos, providing ratings and feedback. The app's recommendation algorithm ensures that users see the most engaging videos based on their preferences, utilizing multiple AI models to rank content.

## How It Works

1. **Recording a Video:**  
   Users open the app and upload a video of themselves performing a recycling action, like a trickshot into the recycling bin or creatively throwing away trash.

2. **AI Analysis:**  
   The video is analyzed using the **LLAVA 1.5-7b-hf** model hosted on **CloudFlare's AI Workspace**, which generates a detailed description of the content.

3. **Agent Interaction:**  
   The description is processed by **Fetch.ai** agents running the **TinyLLaMa-1.1b-chat-v1.0** model. These agents communicate with each other, generate comments, and provide feedback on the video.

4. **Final Rating:**  
   A final AI model evaluates the conversation and descriptions to generate an overall rating for the video. This rating helps rank videos, and the best content is shown to other users.

5. **Data Storage and Communication:**  
   All user data and interactions are stored using **MongoDB Atlas**, while video content is stored on a secure cloud server.

## Challenges

Developing in **Swift** was one of our biggest challenges due to tight timelines and numerous technical hurdles. The amount of issues we encountered with Swift was comparable to all other platforms combined. However, overcoming these issues allowed us to get closer to our goal and learn a lot in the process.

## Accomplishments

- Successfully setting up an **AI pipeline** involving multiple layers of models and agents.
- Getting significant help from mentors, **Fetch.ai**, and **CloudFlare**, which gave us insights into the capabilities of AI agents working together.
- Developing a unique application that combines sustainability and social media elements.

## What We Learned

Building **CleanBucket** from scratch was an immense learning experience. While it's too much to list everything, key lessons include:
- **UI design**: Next time, we would dedicate more time to crafting a more intuitive and user-friendly interface.
- **Data flow**: We learned the importance of thinking about how data will move across platforms and devices before diving into coding.

## What's Next

- **User Feedback Integration:**  
   We would love to integrate user feedback directly into the AI pipeline, allowing users to rate the "coolness" of videos. This would help finetune the final rating system and improve the overall accuracy of predictions.

- **Video Playback Optimization:**  
   We are looking into improving the video playback experience by reducing delays and improving the performance of the app, ensuring smooth interactions for users.
