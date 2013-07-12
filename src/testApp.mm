#include "testApp.h"


//--------------------------------------------------------------
void testApp::setup(){
	//ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
    
	capW = 568;
	capH = 320;
    
#ifdef _USE_LIVE_VIDEO
    vidGrabber.initGrabber(capW, capH);
    capW = vidGrabber.getWidth();
    capH = vidGrabber.getHeight();
#else
    vidPlayer.loadMovie("sample.mov");
    vidPlayer.setLoopState(OF_LOOP_NORMAL);
//    capW = vidPlayer.getWidth();
//    capH = vidPlayer.getHeight();
    vidPlayer.play();
#endif
    
    image.allocate(capW,capH);
	background.allocate(capW,capH);
	diff.allocate(capW,capH);
    
    filter.allocate(capW,capH);
    filter.set(255, 0, 255);
    
    
	bLearnBakground = true;
	threshold = 50;
	
	ofSetFrameRate(30);
    detectedballs = 0;
    prevdetectedballs = 0;
    hysteresis_l=0.05;
    hysteresis_h=0.95;
    state=0;
    

	synth.loadSound("synth.caf");
	synth.setVolume(1.f);
	synth.setMultiPlay(false);
    
}

//--------------------------------------------------------------
void testApp::update(){
    ofBackground(100,100,100);
    
    
    
    
    
    bool bNewFrame = false;
    
#ifdef _USE_LIVE_VIDEO
    vidGrabber.update();
    bNewFrame = vidGrabber.isFrameNew();
#else
    vidPlayer.update();
    bNewFrame = vidPlayer.isFrameNew();
#endif
    
	if (bNewFrame){
        
#ifdef _USE_LIVE_VIDEO
        if( vidGrabber.getPixels() != NULL ){
#else
			if( vidPlayer.getPixels() != NULL && vidPlayer.getWidth() > 0 ){
#endif
                
                
#ifdef _USE_LIVE_VIDEO
                image.setFromPixels(vidGrabber.getPixels(), capW,capH);
#else
                image.setFromPixels(vidPlayer.getPixels(), capW,capH);
#endif
                
                image*=filter;
                
                if (bLearnBakground == true){
                    background = image;		// the = sign copys the pixels from grayImage into grayBg (operator overloading)
                    bLearnBakground = false;
                }
                
                diff = image;
                diff -= background;
                
                graydiff=diff;
                
                // take the abs value of the difference between background and incoming and then threshold:
                //		diff.absDiff(background, image);
                graydiff.threshold(threshold);
                
                // find contours which are between the size of 20 pixels and 1/3 the w*h pixels.
                // also, find holes is set to true so we will get interior contours as well....
                contourFinder.findContours(graydiff, 100, 10000, 10, true);	// find holes
            }
        }
        
        
        
        // update the sound playing system:
        ofSoundUpdate();
    }
    
    //--------------------------------------------------------------
    void testApp::draw(){
        
        ofSetColor(255);
        ofDrawBitmapString(ofToString(ofGetFrameRate()), 20, 20);
        
        ofPushMatrix();
        ofScale(0.5, 0.5, 1);
        
        // draw the incoming, the grayscale, the bg and the thresholded difference
        ofSetHexColor(0xffffff);
        image.draw(0,0);
        background.draw(capW, 0);
        graydiff.draw(0, capH );
        
        // lets draw the contours.
        // this is how to get access to them:
//        for (int i = 0; i < contourFinder.nBlobs; i++){
//            contourFinder.blobs[i].draw(0, capH );
//        }
        
        int detections=0;
        for (int i = 0; i < contourFinder.nBlobs; i++){
            
            
            float ratio = contourFinder.blobs[i].area / (contourFinder.blobs[i].length * contourFinder.blobs[i].length);
            
            
            if(ratio>0.04) {
                detections++;
                contourFinder.blobs[i].draw(360,540);
                stringstream str;
                str << ratio  << endl;
                ofDrawBitmapString(str.str(),
                                   contourFinder.blobs[i].boundingRect.getCenter().x + 360,
                                   contourFinder.blobs[i].boundingRect.getCenter().y + 540);
                
                
                // draw over the centroid if the blob is a hole
                ofSetColor(255);
                if(contourFinder.blobs[i].hole){
                    ofDrawBitmapString("hole",
                                       contourFinder.blobs[i].boundingRect.getCenter().x + 360,
                                       contourFinder.blobs[i].boundingRect.getCenter().y + 540);
                }
            }
        }

        
        
        
        
        ofPopMatrix();
        // finally, a report:
        
        ofSetHexColor(0xffffff);
        char reportStr[1024];
        
        if(detections >=1) {
            detectedballs = detectedballs +0.05*(1.-detectedballs);
        } else {
            detectedballs = detectedballs -0.05*detectedballs;
        }
        
        if(detectedballs>=hysteresis_h && prevdetectedballs<hysteresis_h && state<=0) {
            synth.play();
            state=1;
        } else if(detectedballs<=hysteresis_l && prevdetectedballs>hysteresis_l && state>=1) {
            state=0;
        }
        prevdetectedballs=detectedballs;
        sprintf(reportStr, "Super Golfotron 3000n\nTap to init\nThresh %i\nBalls: %f, FPS: %f", threshold, detectedballs, ofGetFrameRate());
        ofDrawBitmapString(reportStr, 4, 380);
    }
    
    //--------------------------------------------------------------
    void testApp::exit(){
        
    }
    
    //--------------------------------------------------------------
    void testApp::touchDown(ofTouchEventArgs & touch){
        bLearnBakground = true;
        
    }
    
    //--------------------------------------------------------------
    void testApp::touchMoved(ofTouchEventArgs & touch){
        
    }
    
    //--------------------------------------------------------------
    void testApp::touchUp(ofTouchEventArgs & touch){
        
    }
    
    //--------------------------------------------------------------
    void testApp::touchDoubleTap(ofTouchEventArgs & touch){
        
    }
    
    //--------------------------------------------------------------
    void testApp::touchCancelled(ofTouchEventArgs & touch){
        
    }
    
    //--------------------------------------------------------------
    void testApp::lostFocus(){
        
    }
    
    //--------------------------------------------------------------
    void testApp::gotFocus(){
        
    }
    
    //--------------------------------------------------------------
    void testApp::gotMemoryWarning(){
        
    }
    
    //--------------------------------------------------------------
    void testApp::deviceOrientationChanged(int newOrientation){
        
    }
