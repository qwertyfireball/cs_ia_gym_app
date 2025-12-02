from aiortc import RTCPeerConnection, RTCSessionDescription, MediaStreamTrack
from aiortc.sdp import candidate_from_sdp, candidate_to_sdp
import numpy as np #opencv detects images as pixels
from av import VideoFrame # a part of pyav -> a single video frame
import asyncio 
import json #websocket messages are sent in a json format
from websockets.asyncio.server import serve
import mediapipe as mp
import cv2

counter = 0
state = None

class ProcessedVideoTrack(MediaStreamTrack): # class allows store incoming tracks, store opencv processing, define recv()
    kind = "video" #each media track has a "kind" audio video etc so needs to be described, so when recv() is called it outputs a video


    def __init__(self, source_track: MediaStreamTrack):
        super().__init__()
        self.source = source_track
        self.pose = mp.solutions.pose.Pose(min_detection_confidence = 0.5, min_tracking_confidence = 0.5)
        self.mp_pose = mp.solutions.pose
        self.mp_drawing = mp.solutions.drawing_utils
        print("inited")
    
    async def recv(self) -> VideoFrame:
        frame = await self.source.recv()

        def angles(a, b, c) -> int:
            a = np.array([a.x, a.y])
            b = np.array([b.x, b.y])
            c = np.array([c.x, c.y])

            rad = np.arctan2(c[1] - b[1], c[0] - b[0]) - np.arctan2(a[1] - b[1], a[0] - b[0])
            degree = np.degrees(rad)
            return degree

        # def bicep_curl(result): 
        #     left_shoulder = result.pose_landmarks.landmark[mp_pose.PoseLandmark.LEFT_SHOULDER]
        #     left_elbow = result.pose_landmarks.landmark[mp_pose.PoseLandmark.LEFT_ELBOW]
        #     left_wrist = result.pose_landmarks.landmark[mp_pose.PoseLandmark.LEFT_WRIST]

        #     right_shoulder = result.pose_landmarks.landmark[mp_pose.PoseLandmark.RIGHT_SHOULDER]
        #     right_elbow = result.pose_landmarks.landmark[mp_pose.PoseLandmark.RIGHT_ELBOW]
        #     right_wrist = result.pose_landmarks.landmark[mp_pose.PoseLandmark.RIGHT_WRIST]

        #     global counter, state

        #     degree_L = angles(left_shoulder, left_elbow, left_wrist)
        #     degree_R = angles(right_shoulder, right_elbow, right_wrist)

        #     if degree_L and degree_R > 160:
        #         state = "down"
            
        #     if degree_L and degree_R < 50 and state == "down":
        #         state = "up"
        #         counter += 1
        #         print(counter)

        # def squat(result):
        #     left_hip = result.pose_landmarks.landmark[mp_pose.PoseLandmark.LEFT_HIP]
        #     left_knee = result.pose_landmarks.landmark[mp_pose.PoseLandmark.LEFT_KNEE]
        #     left_ankle = result.pose_landmarks.landmark[mp_pose.PoseLandmark.LEFT_ANKLE]

        #     right_hip = result.pose_landmarks.landmark[mp_pose.PoseLandmark.RIGHT_HIP]
        #     right_knee = result.pose_landmarks.landmark[mp_pose.PoseLandmark.RIGHT_KNEE]
        #     right_ankle = result.pose_landmarks.landmark[mp_pose.PoseLandmark.RIGHT_ANKLE]

        #     global counter, state    

        #     degree_L = angles(left_hip, left_knee, left_ankle)
        #     degree_R = angles(right_hip, right_knee, right_ankle)

        #     if degree_L and degree_R > 160:
        #         state = "up"
            
        #     if degree_L and degree_R < 125 and state == "up":
        #         state = "down"
        #         counter += 1
        #         print(counter)

        def lateral_raise(result):
            left_elbow = result.pose_landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_ELBOW]
            left_shoulder = result.pose_landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_SHOULDER]
            left_hip = result.pose_landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_HIP]

            right_elbow = result.pose_landmarks.landmark[self.mp_pose.PoseLandmark.RIGHT_ELBOW]
            right_shoulder = result.pose_landmarks.landmark[self.mp_pose.PoseLandmark.RIGHT_SHOULDER]
            right_hip = result.pose_landmarks.landmark[self.mp_pose.PoseLandmark.RIGHT_HIP]

            global counter, state

            degree_L = angles(left_elbow, left_shoulder, left_hip)
            degree_R = angles(right_elbow, right_shoulder, right_hip)

            if degree_L and degree_R < 50:
                state = "down"
            
            if degree_L and degree_R > 80 and state == "down":
                state = "up"
                counter += 1
                print(counter)

        img = frame.to_ndarray(format = "bgr24")
        result = self.pose.process(cv2.cvtColor(img, cv2.COLOR_BGR2RGB)) #pose.process only takes in numpy not framepy, which is why need: framepy -> numpy -> frampy (output)

        if result.pose_landmarks:
            # place functions here ->
            # bicep_curl(result)
            # squat(result)
            lateral_raise(result)
            self.mp_drawing.draw_landmarks(img, result.pose_landmarks, self.mp_pose.POSE_CONNECTIONS)
            cv2.putText(
                img, f"Reps: {counter}", (50, 50), cv2.FONT_HERSHEY_SIMPLEX | cv2.FONT_ITALIC, 1, (255, 255, 255), 1.5
            )
            print("drawn landmarks")

        new_frame = VideoFrame.from_ndarray(img, format = "bgr24")
        new_frame.pts = frame.pts # pts = when this frame should be shown
        new_frame.time_base = frame.time_base # conversion of pts to seconds
        print("new frame about to be returned")
        return new_frame
    
async def ice(peerConnection: RTCPeerConnection):
    while peerConnection.iceGatheringState != "complete":
        await asyncio.sleep(0.05) #keep connecting until works 
    
async def echoserver(websocket): # server 
    peerConnection = RTCPeerConnection()

    @peerConnection.on("track") # @: a decorator -> takes a function in the form of peerConnection.on("track")(echoserver) / pc.on("track"): when track event occurs, run this function 
    def onTrack(track):
        if track.kind == "video":
            processed = ProcessedVideoTrack(track)
            peerConnection.addTrack(processed)
        
    @peerConnection.on("connectionstatechange")
    async def disconnect():
        if peerConnection.connectionState == ("failed", "disconnected", "closed"):
            await peerConnection.close()

    @peerConnection.on('icecandidate')
    async def trickle_ice(event):
        if event.candidate is not None:
            await websocket.send(json.dumps({
                'type': 'candidate',
                'candidate': {
                'candidate': candidate_to_sdp(event.candidate),
                'sdpMid': event.candidate.sdpMid, 
                'sdpMLineIndex': event.candidate.sdpMLineIndex, 
            }}))

            await websocket.send(json.dumps({
                'type': 'rep_count'
                'value': counter
            }))

    try:
        async for rawJSON in websocket:
            message = json.loads(rawJSON) #message = {type: , sdp:}

            if message.get("type") == "offer": #offer = sdp offer/offerer vs answerer/this means "flutter has sent an offer"
                offer = RTCSessionDescription(sdp=message['sdp'], type="offer") # what flutter is offering
                await peerConnection.setRemoteDescription(offer) 

                answer = await peerConnection.createAnswer()
                await peerConnection.setLocalDescription(answer) # what python wants to recieve
                
                await ice(peerConnection) # Wait for ICE gathering so SDP contains all candidates

                payload = {"type": peerConnection.localDescription.type, "sdp": peerConnection.localDescription.sdp}
                await websocket.send(json.dumps(payload)) # send sdp answer back
            elif message.get('type') == "candidate":
                c = message.get('candidate')
                if c and 'candidate' in c:
                    candidate = candidate_from_sdp(c['candidate'])
                    candidate.sdpMid = c.get("sdpMid") 
                    candidate.sdpMLineIndex = c.get("sdpMLineIndex")
                    await peerConnection.addIceCandidate(candidate)


            elif message.get("type") in ("bye", "close"):
                break
    finally:
        await peerConnection.close()

async def main():
    async with serve(echoserver, "0.0.0.0", 9001) as server:
        print("server is now listening")
        await asyncio.Future() # runs forever

if __name__ == "__main__": 
    asyncio.run(main())


