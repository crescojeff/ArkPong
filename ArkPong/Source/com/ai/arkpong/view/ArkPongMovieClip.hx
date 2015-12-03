package com.ai.arkpong.view;
import openfl.display.BitmapData;
import openfl.display.MovieClip;
import openfl.Assets;

/**
A subclass of openfl MovieClip that adds handy utility methods
*/
class ArkPongMovieClip extends MovieClip{
    public function new() {
        super();
    }

    /**
    Loads an image as the display graphic for this ArkPongMC instance
    */
    public function loadImage(imageURL:String){
        //TODO: load the image at imageURL as the display graphic
        //for this instance of ArkPongMovieClip
        //For the moment, assume the images are local to the app,
        //and will likely come in the form 'assets/imageName'

        var bmpData:BitmapData = Assets.getBitmapData(imageURL);
    }
}
