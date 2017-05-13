package org.dasfoo.delern.listeners;

import android.content.Context;
import android.support.annotation.NonNull;
import android.util.Log;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;

/**
 * Created by katarina on 3/7/17.
 * Listeners whether operation in Firebase was completed. If not, writes log message.
 */
public abstract class AbstractOnFbOperationCompleteListener implements OnCompleteListener<Void> {

    private final String mTag;
    private final Context mContext;
    private String mAddedKey;

    /**
     * Tag for logging. It describes from what class was called.
     *
     * @param tag     tag for logging.
     * @param context context for writing user message.
     */
    public AbstractOnFbOperationCompleteListener(final String tag, final Context context) {
        this.mTag = tag;
        this.mContext = context;
    }

    /**
     * {@inheritDoc}
     * Writes log on failure. Logic for success must be implemented in inherited class.
     */
    @Override
    public final void onComplete(@NonNull final Task task) {
        if (task.isSuccessful()) {
            onOperationSuccess();
        } else {
            Log.e(mTag, "Operation is not completed:", task.getException());
            Toast.makeText(mContext, task.getException().getLocalizedMessage(),
                    Toast.LENGTH_LONG).show();
        }
    }

    /**
     * Handles operation on success result. It has parameter that can be needed for the next
     * operations.
     */
    public abstract void onOperationSuccess();

    /**
     * Getter for key that was generated by FB for a new created record.
     *
     * @return key generated by FB.
     */
    public String getAddedKey() {
        return mAddedKey;
    }

    /**
     * Setter for key that that was generated by FB for a new created record.
     *
     * @param addedKey key generated by FB.
     */
    public void setAddedKey(final String addedKey) {
        this.mAddedKey = addedKey;
    }
}
