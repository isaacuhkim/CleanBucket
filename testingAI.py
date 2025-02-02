import requests
import json
import cv2
import numpy as np
import os
from dotenv import load_dotenv

load_dotenv()

ACCOUNT_ID = os.getenv("ACCOUNT_ID")
AUTH_TOKEN = os.getenv("CLOUDFLARE_TOKEN")

def generate_screenshots(video_name, num_screenshots=5):
    # Open the video file using cv2
    video = cv2.VideoCapture("uploads/" + video_name)

    if not video.isOpened():
        print("Error: Could not open video.")
        return

    fps = video.get(cv2.CAP_PROP_FPS)  # Frames per second
    total_frames = int(video.get(cv2.CAP_PROP_FRAME_COUNT))  # Total number of frames
    duration = total_frames / fps  # Total video duration in seconds
    
    print(f"Video Duration: {duration:.2f} seconds")
    intervals = [i * duration / num_screenshots for i in range(1, num_screenshots + 1)]
    
    # Create a folder to save the screenshots if it doesn't exist
    output_folder = "screenshots/" + video_name
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    for idx, interval in enumerate(intervals):
        frame_number = int(interval * fps) - 1
        video.set(cv2.CAP_PROP_POS_FRAMES, frame_number)
        ret, frame = video.read()

        if not ret:
            print(f"Error: Couldn't read frame at {frame_number}.")
            continue

        # Save the screenshot as an image file
        screenshot_filename = f"{output_folder}/screenshot_{idx}.jpg"
        cv2.imwrite(screenshot_filename, frame)
        print(f"Saved screenshot at {interval:.2f} seconds to {screenshot_filename}")

    # Release the video object
    video.release()
    return(output_folder)

video_name = "IMG_0667.qt" 
folder = generate_screenshots(video_name)

def img_to_text(sc_folder):
    descriptions = "here are the sequential descriptions: "
    for i in range(5):
        with open(sc_folder + "/screenshot_" + str(i) + ".jpg", "rb") as img_file:
            image_data = img_file.read()
        response = requests.post(
        f"https://api.cloudflare.com/client/v4/accounts/{ACCOUNT_ID}/ai/run/@cf/llava-hf/llava-1.5-7b-hf",
            headers={"Authorization": f"Bearer {AUTH_TOKEN}"},
            json={
                "image": list(image_data),
                "prompt": "Describe in 10 words or less EXACTLY what is going on in this image, this image is a part" + str(i) +" of a video of a person throwing recyclables into a bin. focus on the object",
                "repetition_penalty": 1,
                "max_tokens": 512
            }
        )
        if response.status_code == 200:
            data = response.json()
            print("AI Response:", data)
            descriptions += data['result']['description']
        else:
            print(f"Failed to get response from AI, status code: {response.status_code}")
            print("Error:", response.text)

    return descriptions
desc = (img_to_text(folder))

def dead_internet(desc):
    prompt = "write a 25 word social media comment for the video " + desc
    response = requests.post(
    f"https://api.cloudflare.com/client/v4/accounts/{ACCOUNT_ID}/ai/run/@cf/tinyllama/tinyllama-1.1b-chat-v1.0",
        headers={"Authorization": f"Bearer {AUTH_TOKEN}"},
        json={
        "messages": [
            {"role": "system", "content": """You are Dr. Claire, a clinical psychologist with over 15 years of experience helping 
            individuals navigate mental health challenges, particularly anxiety and depression. 
            You are a compassionate listener who creates a safe, non-judgmental space for people to open up. 
            You are patient, empathetic, and take a holistic approach, understanding that everyone journey toward healing is unique. 
            Your tone is calming, reassuring, and supportive. You are browsing a social media platform, and given a description of a video.
            """},
            {"role": "user", "content": prompt}
        ]
        }
    )
    result = response.json()
    print(result)

dead_internet(desc)
