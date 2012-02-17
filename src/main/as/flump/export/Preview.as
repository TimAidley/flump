//
// Flump - Copyright 2012 Three Rings Design

package flump.export {

import flash.filesystem.File;

import executor.Executor;
import executor.load.ImageLoader;
import executor.load.LoadedImage;

import flump.display.Movie;
import flump.xfl.XflLibrary;
import flump.xfl.XflMovie;
import flump.xfl.XflTexture;

import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

import com.threerings.util.Map;
import com.threerings.util.Maps;

import com.threerings.display.Animation;

public class Preview extends Sprite
{
    public function displayAnimation (base :File, lib :XflLibrary, xflMovie :XflMovie) :void {
        loadTextures(base, lib, function (..._) :void {
            var movie :Movie = new Movie(xflMovie, function (symbol :String) :DisplayObject {
                var xflTex :XflTexture = _xflTextures.get(symbol);
                var image :Image = new Image(_textures.get(symbol));
                image.x = xflTex.offset.x;
                image.y = xflTex.offset.y;
                return image;
            });
            addChild(movie);
        });
    }

    public function loadTextures (base :File, lib :XflLibrary, onLoaded :Function) :void {
        var loader :Executor = new Executor();
        for each (var tex :XflTexture in lib.textures) {
            if (_textures.containsKey(tex.name)) continue;
            new ImageLoader().loadFromUrl(tex.exportPath(base).url, loader).succeeded.add(
                textureAdder(tex));
        }
        loader.terminated.add(function (..._) :void { onLoaded(); });
        loader.shutdown();
    }

    public function textureAdder (tex :XflTexture) :Function {
        return function (img :LoadedImage) :void {
            _xflTextures.put(tex.name, tex);
            _textures.put(tex.name, Texture.fromBitmap(img.bitmap));
        };
    }

    public function displayTextures (base :File, lib :XflLibrary) :void {
        loadTextures(base, lib, function (..._) :void {
            var x :int = 0;
            for each (var tex :Texture in _textures.values()) {
                var img :Image = new Image(tex);
                img.x = x;
                x += img.width;
                addChild(img);
            }
        });
    }

    protected const _xflTextures :Map = Maps.newMapOf(String);
    protected const _textures :Map = Maps.newMapOf(String);
}
}
