package de.esys.esysfluttershare;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.app.Activity;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;

/**
 * EsysfluttersharePlugin
 */
public class EsysFlutterSharePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {

    private final String PROVIDER_AUTH_EXT = ".fileprovider.github.com/orgs/esysberlin/esys-flutter-share";
    private static final int SHARE_REQUEST_CODE = 9023;

    private MethodChannel channel;
    private FlutterPluginBinding binding;
    private Activity activity;
    private Result pendingResult;
    private Boolean useSeparateActivity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "channel:github.com/orgs/esysberlin/esys-flutter-share");
        binding = flutterPluginBinding;
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("init")) {
            initPlugin(call.arguments, result);
        }
        if (call.method.equals("text")) {
            text(call.arguments, result);
        }
        if (call.method.equals("file")) {
            file(call.arguments, result);
        }
        if (call.method.equals("files")) {
            files(call.arguments, result);
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        this.activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
        this.activity = null;
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == SHARE_REQUEST_CODE && pendingResult != null) {
            boolean success = (resultCode == Activity.RESULT_OK);
            pendingResult.success(success);
            pendingResult = null;
            return true;
        }

        return false;
    }
    
    private void initPlugin(Object arguments, Result result) {
        useSeparateActivity = (Boolean) arguments;
    }

    private void text(Object arguments, Result result) {
        @SuppressWarnings("unchecked")
        HashMap<String, String> argsMap = (HashMap<String, String>) arguments;
        String title = argsMap.get("title");
        String text = argsMap.get("text");
        String mimeType = argsMap.get("mimeType");
        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        shareIntent.setType(mimeType);
        shareIntent.putExtra(Intent.EXTRA_TEXT, text);
        Intent chooserIntent = Intent.createChooser(shareIntent, title);
        chooserIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        if (useSeparateActivity) chooserIntent.addFlags(FLAG_ACTIVITY_NEW_TASK);
        if (activity != null) {
            pendingResult = result;
            activity.startActivityForResult(chooserIntent, SHARE_REQUEST_CODE);
        } else {
            result.error("NO_ACTIVITY", "No foreground activity", null);
        }
    }

    private void file(Object arguments, Result result) {
        @SuppressWarnings("unchecked")
        HashMap<String, String> argsMap = (HashMap<String, String>) arguments;
        String title = argsMap.get("title");
        String mimeType = argsMap.get("mimeType");
        String text = argsMap.get("text");
        String filePath = argsMap.get("filePath");
        Context activeContext = binding.getApplicationContext();
        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        shareIntent.setType(mimeType);
        File file = new File(filePath);
        String fileProviderAuthority = activeContext.getPackageName() + PROVIDER_AUTH_EXT;
        Uri contentUri = FileProvider.getUriForFile(activeContext, fileProviderAuthority, file);
        shareIntent.putExtra(Intent.EXTRA_STREAM, contentUri);
        if (!text.isEmpty()) shareIntent.putExtra(Intent.EXTRA_TEXT, text);
        Intent chooserIntent = Intent.createChooser(shareIntent, title);
        if (useSeparateActivity) chooserIntent.addFlags(FLAG_ACTIVITY_NEW_TASK);
        List<ResolveInfo> resInfoList = activeContext.getPackageManager().queryIntentActivities(chooserIntent, PackageManager.MATCH_DEFAULT_ONLY);
        for (ResolveInfo resolveInfo : resInfoList) {
            String packageName = resolveInfo.activityInfo.packageName;
            activeContext.grantUriPermission(packageName, contentUri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }
        if (activity != null) {
            pendingResult = result;
            activity.startActivityForResult(chooserIntent, SHARE_REQUEST_CODE);
        } else {
            result.error("NO_ACTIVITY", "No foreground activity", null);
        }
    }

    private void files(Object arguments, Result result) {
        @SuppressWarnings("unchecked")
        HashMap<String, Object> argsMap = (HashMap<String, Object>) arguments;
        String title = (String) argsMap.get("title");
        @SuppressWarnings("unchecked")
        ArrayList<String> filePaths = (ArrayList<String>) argsMap.get("filePaths");
        ArrayList<String> mimeTypes = (ArrayList<String>) argsMap.get("mimeTypes");
        String text = (String) argsMap.get("text");
        Context activeContext = binding.getApplicationContext();
        Intent shareIntent = new Intent();
        ArrayList<Uri> contentUris = new ArrayList<>();
        for (String filePath : filePaths) {
            File file = new File(filePath);
            String fileProviderAuthority = activeContext.getPackageName() + PROVIDER_AUTH_EXT;
            Uri contentUri = FileProvider.getUriForFile(activeContext, fileProviderAuthority, file);
            contentUris.add(contentUri);
        }
        if (contentUris.size() == 1) {
            shareIntent.setAction(Intent.ACTION_SEND);
            shareIntent.putExtra(Intent.EXTRA_STREAM, contentUris.get(0));
        } else {
            shareIntent.setAction(Intent.ACTION_SEND_MULTIPLE);
            shareIntent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, contentUris);
        }
        String mimeType = reduceMimeTypes(mimeTypes);
        shareIntent.setType(mimeType);
        if (!text.isEmpty()) shareIntent.putExtra(Intent.EXTRA_TEXT, text);
        Intent chooserIntent = Intent.createChooser(shareIntent, title);
        if (useSeparateActivity) chooserIntent.addFlags(FLAG_ACTIVITY_NEW_TASK);
        List<ResolveInfo> resInfoList = activeContext.getPackageManager().queryIntentActivities(chooserIntent, PackageManager.MATCH_DEFAULT_ONLY);
        for (ResolveInfo resolveInfo : resInfoList) {
            String packageName = resolveInfo.activityInfo.packageName;
            for(Uri uri: contentUris){
                activeContext.grantUriPermission(packageName, uri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
        }
        if (activity != null) {
            pendingResult = result;
            activity.startActivityForResult(chooserIntent, SHARE_REQUEST_CODE);
        } else {
            result.error("NO_ACTIVITY", "No foreground activity", null);
        }
    }

    /**
     * Reduces provided MIME types to a common one to provide [Intent] with a correct type
     * to share multiple files
     */
    private String reduceMimeTypes(ArrayList<String> mimeTypes) {
        String reducedMimeType = "*/*";
        int size = mimeTypes.size();

        if (size == 1) {
            reducedMimeType = mimeTypes.get(0);
        } else if (size > 1) {
            String commonMimeType = mimeTypes.get(0);
            String commonMimeTypeBase = getMimeTypeBase(commonMimeType);
            for (int i = 1; i < size; ++i) {
                String iterabelType = mimeTypes.get(i);
                if (!commonMimeType.equals(iterabelType)) {
                    String iterableTypeBase = getMimeTypeBase(iterabelType);
                    if (commonMimeTypeBase == iterableTypeBase) {
                        commonMimeType = iterableTypeBase + "/*";
                    } else {
                        commonMimeType = "*/*";
                        break;
                    }
                }
            }
            reducedMimeType = commonMimeType;
        }
        return reducedMimeType;
    }

    /**
     * Returns the first part of provided MIME type, which comes before '/' symbol
     */
    private String getMimeTypeBase(String mimeType) {
        if (mimeType == null || !mimeType.contains("/")) {
            return "*";
        } else {
            return mimeType.substring(0, mimeType.indexOf("/"));
        }
    }
}