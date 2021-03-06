---
title: Setup navigation
description: In this step you will setup navigation component.
---

# Setup navigation

## Create application nav graph

Right click at `res` folder, select `New` > `Android resource file`:

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/new-android-resource-file.png
```

Enter `app_nav_graph` as file name, select `Navigation` as resource type and press `OK` button.

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/new-app-nav-graph.png
```

Click the `Code` button in top right corner and replace it's content with below code snippet to set navigation graph for the application:

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/show-code-view.png
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<navigation xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        xmlns:tools="http://schemas.android.com/tools"
        android:id="@+id/app_navigation_graph"
        app:startDestination="@id/loginFragment">
    <fragment
            android:id="@+id/loginFragment"
            android:name="com.vonage.tutorial.messaging.LoginFragment"
            android:label="LoginFragment"
            tools:layout="@layout/fragment_login">
        <action
                android:id="@+id/action_loginFragment_to_chatFragment"
                app:destination="@id/chatFragment" />
    </fragment>
    <fragment
            android:id="@+id/chatFragment"
            android:name="com.vonage.tutorial.messaging.ChatFragment"
            android:label="ChatFragment"
            tools:layout="@layout/fragment_chat"/>
</navigation>
```

Navigation graph defines navigation directions between fragments in the application. Notice that now `LoginFragment` is now start fragment in the application

## Add `NavHostFragment`

Set `app_nav_graph` as main navigation graph of the application. Open the `activity_main.xml`, click `Code` button in top right corner file and replace XML layout code:

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/activity-main-layout-file.png
```

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/show-code-view.png
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        xmlns:tools="http://schemas.android.com/tools"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical"
        tools:context=".MainActivity">

    <fragment
            android:id="@+id/navHostFragment"
            android:name="androidx.navigation.fragment.NavHostFragment"
            android:layout_width="0dp"
            android:layout_height="0dp"
            app:defaultNavHost="true"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintLeft_toLeftOf="parent"
            app:layout_constraintRight_toRightOf="parent"
            app:layout_constraintTop_toTopOf="parent"
            app:navGraph="@navigation/app_nav_graph" />

</androidx.constraintlayout.widget.ConstraintLayout>
```

Now `NavHostFragment` with navigation graph (`@navigation/app_nav_graph`) will serve as main navigation mechanism within this application.

## Configure navigation in the `MainActivity`

Define two helpers - `BackPressHandler` and `NavManager` to simplify the navigation

### Create `BackPressHandler` interface

`BackPressHandler` interface will help with handling pressing of the back button. Right click on `com.vonage.tutorial.messaging` package, select `New` > `Java Class`, enter `BackPressHandler` as file name, select `Interface`. Add `onBackPressed` method to the `BackPressHandler` interface:

```java
package com.vonage.tutorial.messaging;

public interface BackPressHandler {
    void onBackPressed();
}
```

> **NOTE** You can also copy the above code snippet to clipboard, select `messaging` package in Android Studio and paste it - this will create `BackPressHandler.kt` file containing above code.

### Create `NavManager` object

`NavManager` object will allow to navigate directly from `ViewModel` by storing reference to navigation controller.

Right click on `com.vonage.tutorial.messaging` package, select `New` > `Java Class`, enter `NavManager` as file name, select `Class`. Replace the file contents with the following code:

```java
package com.vonage.tutorial.messaging;

import androidx.navigation.NavController;
import androidx.navigation.NavDirections;

public final class NavManager {

    private static NavManager INSTANCE;
    NavController navController;

    public static NavManager getInstance() {
        if (INSTANCE == null) {
            INSTANCE = new NavManager();
        }

        return INSTANCE;
    }

    public void init(NavController navController) {
        this.navController = navController;
    }

    public void navigate(NavDirections navDirections) {
        navController.navigate(navDirections);
    }
}
```

### Update `MainActivity`

Add `onBackPressed` method to the `MainActivity`:

```java
@Override
public void onBackPressed() {
    FragmentManager childFragmentManager =
            getSupportFragmentManager().getPrimaryNavigationFragment().getChildFragmentManager();

    Fragment currentNavigationFragment = childFragmentManager.getFragments().get(0);
    BackPressHandler backPressHandler = (BackPressHandler) currentNavigationFragment;

    if (backPressHandler != null) {
        backPressHandler.onBackPressed();
    }

    super.onBackPressed();
}
```

To initialize `NavManager` call it's `init` method from `MainActivity.onCreate` method:

```java
@Override
protected void onCreate(@Nullable Bundle savedInstanceState) {
    
    // ...

    NavController navController = Navigation.findNavController(this, R.id.navHostFragment);
    NavManager.getInstance().init(navController);
}
```

Run `Build` > `Make project` to make sure project is compiling.