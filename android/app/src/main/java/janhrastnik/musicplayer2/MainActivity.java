package janhrastnik.musicplayer2;

import android.media.MediaMetadataRetriever;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.mpatric.mp3agic.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "demo.janhrastnik.com/info";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

        Map<String, Object> arguments = methodCall.arguments();
        MediaMetadataRetriever mmr = new MediaMetadataRetriever();
        if (methodCall.method.equals("getMetaData")) {
          String filepath = (String) arguments.get("filepath");
          System.out.print(filepath);
          System.out.print(filepath);
          System.out.print(filepath);
          System.out.print(filepath);
          List<String> l = new ArrayList();
          mmr.setDataSource(filepath);
          String title = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE);
          String artist = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST);
          String album = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM);
          String number = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER);
          l.add(title);
          l.add(artist);
          l.add("");
          l.add(album);
          l.add(number);
          result.success(l);
        }

      }
    });
  }
}
