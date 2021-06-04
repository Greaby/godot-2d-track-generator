# Godot 2D Track Generator

## Project Description

This class generates a circuit procedurally on a 2D tilemap. You can define conditions for the size of the path and the priority given to straight lines.

## How to use

1. Add the TrackGenerator object in your scene.
2. Configure the parameters (Area, Min length, Max length, ..)
3. Generate a track with `$TrackGenerator.generate()`, when finished it returns an array of Vector2.
4. Create your Tilemap from the array.

You can find an example of how to generate and create a Tilemap in `main.gd`.

## Dependencies

This project require Godot Engine 3.3.

## Licenses

-   The source code is available under the MIT license.
-   Art Assets are available under CC0 1.0 Universal ([Racing Pack by Kenney](https://www.kenney.nl/assets/racing-pack))
