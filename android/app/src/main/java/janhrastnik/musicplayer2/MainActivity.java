package janhrastnik.musicplayer2;

import android.media.MediaMetadataRetriever;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.mpatric.mp3agic.*;

import java.io.IOException;
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
        String message = "ayyy";
        MediaMetadataRetriever mmr = new MediaMetadataRetriever();

        if (methodCall.method.equals("getMetaData")) {
          String filepath = (String) arguments.get("filepath");
          mmr.setDataSource(filepath);
          String title = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE);
          result.success(title);
        }

      }
    });
  }
}
