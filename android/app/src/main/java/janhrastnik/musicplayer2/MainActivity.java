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
  private static final MediaMetadataRetriever mmr = new MediaMetadataRetriever();

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        Map<String, Object> arguments = methodCall.arguments();
        if (methodCall.method.equals("getMetaData")) {
          String filepath = (String) arguments.get("filepath");
          List l = new ArrayList();
          mmr.setDataSource(filepath);
          l.add(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE));
          l.add(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST));
          try {
            l.add(mmr.getEmbeddedPicture());
          } catch (Exception e) {
            l.add("");
          }
          l.add(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM));
          l.add(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER));
          mmr.release();
          result.success(l);
        }

      }
    });
  }
}
