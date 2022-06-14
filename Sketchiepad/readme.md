# Sketchiepad
## What is Sketchiepad??
Sketchiepad is a piece of s--- that allows you to code animations thanks to the amazing Processing 3 rendering engine. It essentially simplifies the process of rendering bitmaps to a canvas and recording them as frames, complete with background sound/music and tools to make it easier to make your scene pretty without having to reposition everything by entering numbers repeatedly until it's in the right place.

## Features
- Automatically load images, sounds, and shaders from their respective folders inside of `data`, so you don't need to worry about loading them in the setup() statement
- Load-on-go feature that loads images as required during the animation. Causes slowdowns during the animation, but reduces initial load time since it's not loading everything at once.
- Cache and shrink images so that they display and load faster
- Click, drag, move, and resize sprites while your animation is running, with their positions and states persisting each run.
- X & Y resize and vertex repositioning modes for sprites
- Lock sprites so that you don't accidentally move them out of place.
- Seek in the video and move forwards/backwards.
- Pause/play video
- Super simple and useful syntax to use in `sketchpad.pde` including but not limited to:
    - sprite()
    - back()
    - img()
    - size()
    - bop()
    - playMusic()

- Keeps background sound and music in sync with the animation, even if it lags or the framerate is inconsistant.
- Super useful beats class that can be used to sync your music to frame-perfect timing functions, to create music videos.
- Shader post processing filter. You can add as many post-processing shaders as you want, the sky's the limit!
- Minify image attribute. Automatically removes blank transparent space around an image so that its width and height is flush against the actual image without gaps.
- Many adjustable and easy-to-edit attributes in sketchpad such as frameWidth, frameHeight, framerate, interval, record on/off, exit when music ends on/off, etc.
- Internal console within the animation display that shows exactly what sketchiepad is doing, as well as warning such as accessing a file that does not exist.
- Prolly loads more little trinkets that I forgot to add here.

# Documentation
Note: documentation is very much incomplete, but I'll try my best.

## Notes and must-knows
Sketchiepad is really designed around one concept: KISS, or; keep it simple, stupid. This means that Sketchiepad is really just "code animation, do some stuff automatically cus we're lazy, das it". It was also originally designed to be a music video creator, so keep that in mind too.

Oh, and also, I created that when I was still very much still learning how to make clean code, so the code you'll see here is  m e s s y   but oh well what can ya do about it.

So if you're going to use sketchiepad, be warned, it's made to make it easier to animate, but at the same time, don't expect too much from it. That is, unless you like reading through confusing code.

Now let's get into the basics.

## Getting started.
Every one of those files you see, `console.pde`, `Sketchiepad.pde`, `engine.pde` can be safely ignored. Unless you want to do some cool advanced trick or something, they're not really worth bothering with.

The only file you DO want to bother with is `sketchpad.pde`, not to be confused with `Sketchiepad.pde`. This is where you'll see all your code. And you'll be greeted with a friendly boilerplate with the following:
- Settings
- imgAttributes
- ready()
- looper()

What each of those do, we'll get back to later. I want you to look next into the `data` folder, assuming it's been set up. Here, you'll find the following folders:
- engine; stores core files for sketchiepad to work. This can be ignored for now.
- font; stores text fonts of course
- frames; stores the output frames when you record the animation, so it can be compiled into a mov or an mp4.
- img; where all of your bitmaps and images are stored. Can be various file types, such as png, jpg, gif, tga, etc.
- music; where your music is stored.
- shaders; where your glsl files are stored.
- sprites; attribute information about sprites. This can be ignored for now.

Here you can load all of your assets into the appropriate file folders, and they will be automatically loaded into your project. In the case of images, they will be automatically scaled down so they render and load faster when you're not recording your project.

Now, back to `sketchpad.pde`.

- Settings
Used to specify the properties of your project. They're pretty self-explainatory, but word of warning(s), make sure `rec` is set to false while you make your project, otherwise Sketchiepad will write frames to your disk and render the video in full quality, which will render your project very slowly.
Also keep clear of `renderScale` and `interval` as they're not implemented properly and could make your project bug out.

- imgAttributes
This is used to define attributes about each image. So far there's only the `mini` attribute, which removes transparent areas around the image. To apply this attribute, add a string to this array in the following format;
`IMG_NAME:mini`

or, if you want to apply to all images:
`ALL:mini`

- ready()
This is where your setup code goes. Typically, you'd only have playMusic stored in there. Do not load any images inside this function, this is done automatically in the background.

- looper()
The main attraction. Literally, it's just your main code looping statement that executes everytime a frame is about to be drawn.

Inside your looper statement, this is where you use the syntax that you see in `void.pde`. For starters, try `sprite(id, image_name)`. `id` can be literally anything you want, as long as it stays the same whenever you run the program. `image_name` is the name of an image in your `img` folder, with the extension (like `.png`) ommited.

When you start up sketchiepad, you will (hopefully) find your image displayed on the screen, just like that. If you click and drag on the image, you will find you can reposition it. If you click the little square at the bottom-right corner, you can drag and resize the image.

That about it for getting started cus honestly i'm not sure anybody's gonna be using this. Maybe i might update this later idk.

## Reference.
### Keys
- `o`  Set sprite to X & Y scaling mode.
- `p`  Set sprite to X / Y scaling mode, not implemented yet so it will make the sprite invisible.
- `[`  Set sprite to vertex mode.
- `]`  Set sprite to rotate mode, not yet fully implemented and will probably not scale correctly.

- `w`  Press and hold to show the console. Press once to make any console text disappear.
- `r`  Show the borders of all sprites.

- `[left arrow]`   go backwards 2 seconds.
- `[right arrow]`  go forwards 2 seconds
- `<`              go backwards 1 frame.
- `>`              go forwards 1 frame.
- `[space]`        play/pause animation.


### sketchpad syntax
- `framecount`       The current frame from the start of the animation.
- `dis`              Instance of the canvas from sketchie.draw.display. Use it to draw anything!
- Can't be bothered with the rest.