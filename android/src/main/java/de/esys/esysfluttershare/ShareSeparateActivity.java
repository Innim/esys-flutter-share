package de.esys.esysfluttershare;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

public class ShareSeparateActivity extends AppCompatActivity {
    private boolean wasStopped = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(new View(this));

        ActivityResultLauncher<Intent> mStartForResult = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(),
                result -> {
                    /*
                    For sharing intents using StartActivityForResult(),
                    the result code is often RESULT_CANCELED,
                    as share targets don't always call setResult().
                    If our activity was sent to the background and we get any result,
                    treat it as a successful share initiation.
                    If, however, the current activity was not stopped (remained in the foreground),
                    it likely means the user minimized the app
                    or pressed the system Back button before completing the share.
                    */
                    sendShareResult(wasStopped);
                }
        );

        Intent originalIntent = getIntent();
        if (originalIntent != null && originalIntent.hasExtra("chooser_intent")) {
            Intent chooserIntent = originalIntent.getParcelableExtra("chooser_intent");


            if (chooserIntent != null) {
                chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_MULTIPLE_TASK);
                mStartForResult.launch(chooserIntent);
            } else {
                sendShareResult(false);
            }
        } else {
            sendShareResult(false);
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        wasStopped = true;
    }

    private void sendShareResult(boolean success) {
        Intent resultIntent = new Intent("de.esys.esysfluttershare.ACTION_SHARE_RESULT");
        resultIntent.putExtra("share_result", success);
        sendBroadcast(resultIntent);

        finish();
    }
}
