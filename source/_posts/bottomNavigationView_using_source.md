# 底部导航-BottomNavigationView 的使用及源码分析
---
title: 底部导航-BottomNavigationView 的使用及源码分析
date: 2018-09-04 22:06:25
categories: [android,学习笔记]
tags: [android,BottomNavigationView,Design]
---

[toc]

目前市面上很多 APP 都有底部导航的功能，实现底部导航的方式也有很多种,如：

- ① 、使用原生控件 ：`TabHost` 、`LinearLayout`  /` RelativeLayout`、`RadioButton` 等；
- ② 、使用 [Design](https://developer.android.com/reference/android/support/design/package-summary) 库中的 [TabLayout]() 或 **[BottomNavigationView](https://developer.android.com/reference/android/support/design/widget/BottomNavigationView)** 实现；<!--more-->
- ③、使用第三方库 ([FlycoTabLayout](https://github.com/H07000223/FlycoTabLayout)/...) 实现；
- ④、自定义控件实现;
- ...

总之，根据自己的实际需求可以选择不同的实现方案。这里主要介绍 [BottomNavigationView](https://developer.android.com/reference/android/support/design/widget/BottomNavigationView)  的实现方式，以及 SDK28 前后的差异。


## 一、实现底部导航

首先添加 `Design` 库的依赖：

```
implementation "com.android.support:design:27.1.1"
```

然后,在 `menu` 目录下定义 tab 的菜单,例如 `res/menu/menu_navigation_tab.xml`：

```
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item
        android:id="@+id/navi_home"
        android:icon="@drawable/ic_home_black_24dp"
        android:title="首页"/>
    
    <item
        android:id="@+id/navi_order"
        android:icon="@drawable/ic_view_list_black_24dp"
        android:title="订单"/>
    
    <item
        android:id="@+id/navi_cart"
        android:icon="@drawable/ic_local_grocery_store_black_24dp"
        android:title="购物车"/>
    
    <item
        android:id="@+id/navi_mine"
        android:icon="@drawable/ic_person_black_24dp"
        android:title="我的"/>
</menu>
```

接着添加 `BottomNavigationView` 到布局中，如下主要代码：

```
<android.support.design.widget.BottomNavigationView
    android:id="@+id/navigation_view"
    android:layout_width="match_parent"
    android:layout_height="?attr/actionBarSize"
    android:background="@android:color/white"
    app:itemIconTint="@color/color_navigation_item"
    app:itemTextColor="@color/color_navigation_item"
    app:layout_constraintBottom_toBottomOf="parent"
    app:layout_constraintLeft_toLeftOf="parent"
    app:layout_constraintRight_toRightOf="parent"
    app:layout_constraintTop_toBottomOf="@id/viewpager"
    app:menu="@menu/menu_navigation">
</android.support.design.widget.BottomNavigationView>
```
> 注意 ：`menu` 指定tab 显示菜单；`itemIconTint` 和 `itemTextColor` 对应为指定 tab 的 icon 和文本颜色(通过定义 color ,指定不同选中状态的颜色)。

最后在 对应的 activity 中对 `BottomNavigationView` 添加 item 选中监听，配合 `ViewPager` 实现界面切换：

![](http://img.imtianx.cn/2018/0904/aty_bnv_init.png?imageView2/0/q/75|watermark/2/text/aHR0cDovL2ltdGlhbnguY24v/font/5b6u6L2v6ZuF6buR/fontsize/1200/fill/I0Y4MEIwQg==/dissolve/100/gravity/SouthEast/dx/20/dy/20)

上述实现较为简单，预览效果如下左图所示：

4个tab： ![图一](http://img.imtianx.cn/2018/0904/tab_4_before_28.gif)                3个tab : ![](http://img.imtianx.cn/2018/0904/tab_3_before_28.gif)

> 注意：如上图所示，当 tab 操作三个，选中的 item 就会有偏移效果，并且只有选中的 item 显示文本。

## 二、tab 偏移问题

对于上面所出现的3个以上tab 会出现偏移问题，通过查看源码，[BottomNavigationView](http://androidxref.com/8.1.0_r33/xref/frameworks/support/design/src/android/support/design/widget/BottomNavigationView.java) 的菜单是由 [BottomNavigationMenuView](http://androidxref.com/8.1.0_r33/xref/frameworks/support/design/src/android/support/design/internal/BottomNavigationMenuView.java) 控制的，如下构造方法中对 `BottomNavigationMenuView` 的初始化及相关属性设置的部分代码 ：

```
 public BottomNavigationView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        // Create the menu
        mMenu = new BottomNavigationMenu(context);

        mMenuView = new BottomNavigationMenuView(context);
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.CENTER;
        mMenuView.setLayoutParams(params);

        mPresenter.setBottomNavigationMenuView(mMenuView);
        mPresenter.setId(MENU_PRESENTER_ID);
        mMenuView.setPresenter(mPresenter);
        mMenu.addMenuPresenter(mPresenter);
        mPresenter.initForMenu(getContext(), mMenu);

        // Custom attributes
        TintTypedArray a = TintTypedArray.obtainStyledAttributes(context, attrs,
                R.styleable.BottomNavigationView, defStyleAttr,
                R.style.Widget_Design_BottomNavigationView);

        if (a.hasValue(R.styleable.BottomNavigationView_itemIconTint)) {
            mMenuView.setIconTintList(
                    a.getColorStateList(R.styleable.BottomNavigationView_itemIconTint));
        } else {
            mMenuView.setIconTintList(
                    createDefaultColorStateList(android.R.attr.textColorSecondary));
        }
        if (a.hasValue(R.styleable.BottomNavigationView_itemTextColor)) {
            mMenuView.setItemTextColor(
                    a.getColorStateList(R.styleable.BottomNavigationView_itemTextColor));
        } else {
            mMenuView.setItemTextColor(
                    createDefaultColorStateList(android.R.attr.textColorSecondary));
        }
        if (a.hasValue(R.styleable.BottomNavigationView_elevation)) {
            ViewCompat.setElevation(this, a.getDimensionPixelSize(
                    R.styleable.BottomNavigationView_elevation, 0));
        }

        int itemBackground = a.getResourceId(R.styleable.BottomNavigationView_itemBackground, 0);
        mMenuView.setItemBackgroundRes(itemBackground);

        if (a.hasValue(R.styleable.BottomNavigationView_menu)) {
            inflateMenu(a.getResourceId(R.styleable.BottomNavigationView_menu, 0));
        }
        a.recycle();
        addView(mMenuView, params);
        // ...
}

```
而 `BottomNavigationMenuView` 中的 item 是一个包含图片文本的自定义控件-- [BottomNavigationItemView](http://androidxref.com/8.1.0_r33/xref/frameworks/support/design/src/android/support/design/internal/BottomNavigationItemView.java) 类型的数组保存的。在 `BottomNavigationItemView` 中对于不同的模式和选中状态，设置 item 的 icon 和 label 的显示，如下部分代码：

```
// 偏移模式，默认 false
 private boolean mShiftingMode;
 
public BottomNavigationItemView(Context context, AttributeSet attrs, int defStyleAttr) {
    // ...
    int inactiveLabelSize =
                res.getDimensionPixelSize(R.dimen.design_bottom_navigation_text_size);// 12sp
    int activeLabelSize = res.getDimensionPixelSize(
                R.dimen.design_bottom_navigation_active_text_size);//14sp
    mShiftAmount = inactiveLabelSize - activeLabelSize;// inactiveLabelSize < activeLabelSize 为 false
    mShiftAmount = inactiveLabelSize - activeLabelSize;
    // label 选中缩放比例
    mScaleUpFactor = 1f * activeLabelSize / inactiveLabelSize;
    // label 隐藏缩放比例
    mScaleDownFactor = 1f * inactiveLabelSize / activeLabelSize;
    // ...
}

// 设置偏移模式
public void setShiftingMode(boolean enabled) {
    mShiftingMode = enabled;
}
// 设置 title
@Override
public void setTitle(CharSequence title) {
    mSmallLabel.setText(title);
    mLargeLabel.setText(title);
}
// ...
@Override
public void setChecked(boolean checked) {
 if (mShiftingMode) {
        if (checked) {
            LayoutParams iconParams = (LayoutParams) mIcon.getLayoutParams();
            iconParams.gravity = Gravity.CENTER_HORIZONTAL | Gravity.TOP;
            iconParams.topMargin = mDefaultMargin;
            mIcon.setLayoutParams(iconParams);
            // 选中状态，显示文本，设置缩放
            mLargeLabel.setVisibility(VISIBLE);
            mLargeLabel.setScaleX(1f);
            mLargeLabel.setScaleY(1f);
        } else {
            LayoutParams iconParams = (LayoutParams) mIcon.getLayoutParams();
            iconParams.gravity = Gravity.CENTER;
            iconParams.topMargin = mDefaultMargin;
            mIcon.setLayoutParams(iconParams);
            // 未选中状态，隐藏文本，设置缩放一半动画
            mLargeLabel.setVisibility(INVISIBLE);
            mLargeLabel.setScaleX(0.5f);
            mLargeLabel.setScaleY(0.5f);
        }
        mSmallLabel.setVisibility(INVISIBLE);
    } else {
        if (checked) {
            LayoutParams iconParams = (LayoutParams) mIcon.getLayoutParams();
            iconParams.gravity = Gravity.CENTER_HORIZONTAL | Gravity.TOP;
            iconParams.topMargin = mDefaultMargin + mShiftAmount;
            mIcon.setLayoutParams(iconParams);
            // 选中，选中 label 显示，未选中 label 隐藏
            mLargeLabel.setVisibility(VISIBLE);
            mSmallLabel.setVisibility(INVISIBLE);

            mLargeLabel.setScaleX(1f);
            mLargeLabel.setScaleY(1f);
            mSmallLabel.setScaleX(mScaleUpFactor);
            mSmallLabel.setScaleY(mScaleUpFactor);
        } else {
            LayoutParams iconParams = (LayoutParams) mIcon.getLayoutParams();
            iconParams.gravity = Gravity.CENTER_HORIZONTAL | Gravity.TOP;
            iconParams.topMargin = mDefaultMargin;
            mIcon.setLayoutParams(iconParams);
            // 未选中，选中 label 隐藏，未选中 label 显示
            mLargeLabel.setVisibility(INVISIBLE);
            mSmallLabel.setVisibility(VISIBLE);

            mLargeLabel.setScaleX(mScaleDownFactor);
            mLargeLabel.setScaleY(mScaleDownFactor);
            mSmallLabel.setScaleX(1f);
            mSmallLabel.setScaleY(1f);
        }
    }
    // ...
}
```

> mLargeLabel 和 mSmallLabel 均表示 菜单文本，只是前者是选中状态，后者是未选中状态展示；对两个 label 设置相应的缩放比例，实现切换 tab 时的动画视差效果。同时，在 `mShiftingMode` 为 **false** 下可以保证 label 的一直显示以及 item 的间距均衡。

通过上面的分析，知道了 tab 设置文本显示的根源，但是其 显示与否还与 `mShiftingMode` 相关，毕竟 tab 数量在3前后不同。

接着回头查看 `BottomNavigationMenuView` 源码，`mShiftingMode` 的设置 如下：

```
// 偏移模式
private boolean mShiftingMode = true;
// 菜单 item
private BottomNavigationItemView[] mButtons;

private final Pools.Pool<BottomNavigationItemView> mItemPool = new Pools.SynchronizedPool<>(5);
  
private MenuBuilder mMenu;

mButtons = new BottomNavigationItemView[mMenu.size()];
// 以3为分界线，来设置不同的偏移模式
mShiftingMode = mMenu.size() > 3;
for (int i = 0; i < mMenu.size(); i++) {
    mPresenter.setUpdateSuspended(true);
    mMenu.getItem(i).setCheckable(true);
    mPresenter.setUpdateSuspended(false);
    BottomNavigationItemView child = getNewItem();
    mButtons[i] = child;
    child.setIconTintList(mItemIconTint);
    child.setTextColor(mItemTextColor);
    child.setItemBackground(mItemBackgroundRes);
    // 设置偏移
    child.setShiftingMode(mShiftingMode);
    child.initialize((MenuItemImpl) mMenu.getItem(i), 0);
    child.setItemPosition(i);
    child.setOnClickListener(mOnClickListener);
    addView(child);
}

// 获取 item ,mItemPool 的最大值为5 ，限制了最多5个 tab
private BottomNavigationItemView getNewItem() {
    BottomNavigationItemView item = mItemPool.acquire();
    if (item == null) {
        item = new BottomNavigationItemView(getContext());
    }
    return item;
}

```
通过上面的代码，彻底知道了 tab 个数在3前后 菜单的偏移模式不同，所以可以修改 `mShiftingMode` 属性来保证 tab 操作3个后的显示模式，但是，`BottomNavigationMenuView` 并未开放相关方法，因此可以通过反射修改 `mShiftingMode` 的值，以及遍历菜单修改相关属性，如下：

```
object NavigationViewHelper {
    @SuppressLint("RestrictedApi")
    fun disableShiftingMode(view: BottomNavigationView) {
        val menuView = view.getChildAt(0) as BottomNavigationMenuView
        if (menuView.childCount > 3) {
            try {
                val shiftingMode = menuView::class.java.getDeclaredField("mShiftingMode")
                shiftingMode.apply {
                    isAccessible = true
                    setBoolean(menuView, false)
                    isAccessible = false
                }
                menuView.forEachChild {
                    (it as BottomNavigationItemView).apply {
                        setShiftingMode(false)
                        // reset check state to update it
                        setChecked(itemData.isChecked)
                    }
                }
            } catch (e: NoSuchFieldException) {
                Log.e("tx", "NavigationViewHelper: Unable to get shiftMode field", e)
            } catch (e: IllegalAccessException) {
                Log.e("tx", "NavigationViewHelper: Unable to change value of shiftMode", e)
            }
        }
    }

}
```
使用上面的工具类可以使 tab 个数在5个内的文本显示、间距相同。


## 三、SDK28 以后相关 API 的变更
最近将项目的 `compile sdk` 和 `support` 相关库升级到28以后，上述的工具类失效，编译无法通过，发现源码中 ，移除了 `mShiftingMode` 属性和 `setShiftingMode` 方法。
这里以 `28.0.0-rc01` 的 `support` 库为例进行分析 (如需使用其他版本，请查看 [google maven repo](https://dl.google.com/dl/android/maven2/index.html) )。

**主要的变动有：**

- 对于 `BottomNavigationItemView`,原始的 `mShiftingMode` 换成了 `isShifting` ,并且添加 `labelVisibilityMode` 属性。
- 对于 `BottomNavigationMenuView` ,移除了 boolean 类型的 `mShiftingMode` 属性，取而代之的是 int 类型的 `labelVisibilityMode`。
- 对于 `BottomNavigationView` ,添加字自定义属性 `labelVisibilityMode`;


这里从 `BottomNavigationView` 源码看起，在 28 以后，新增的自定属性 `labelVisibilityMode` 取值为：

```
<declare-styleable name="BottomNavigationView"><attr name="menu"/><attr name="labelVisibilityMode">
  <!-- 自动 ，和 menu 的 item 数目有关 -->
  <enum name="auto" value="-1"/>
  <!-- 选中状态显示 label -->
  <enum name="selected" value="0"/>
  <!-- 全部显示 label -->
  <enum name="labeled" value="1"/>
  <!-- 全部不显示 label -->
  <enum name="unlabeled" value="2"/>
```

其中，默认为 `-1`,如下获取自定义属性和设置 menu 的 labelVisibilityMode 的源码：

```
 private final BottomNavigationMenuView menuView;
 
// 获取自定义属性值，默认 -1
this.setLabelVisibilityMode(a.getInteger(styleable.BottomNavigationView_labelVisibilityMode, -1));

// 设置 menu 的 labelVisibilityMode
public void setLabelVisibilityMode(int labelVisibilityMode) {
    if (this.menuView.getLabelVisibilityMode() != labelVisibilityMode) {
        this.menuView.setLabelVisibilityMode(labelVisibilityMode);
        this.presenter.updateMenuView(false);
    }
}
```

接着，查看 `BottomNavigationMenuView` 的相关源码：

```
boolean shifting = this.isShifting(this.labelVisibilityMode, this.menu.getVisibleItems().size());
for(int i = 0; i < menuSize; ++i) {
    this.presenter.setUpdateSuspended(true);
    this.buttons[i].setLabelVisibilityMode(this.labelVisibilityMode);
    // 设置偏移
    this.buttons[i].setShifting(shifting);
    this.buttons[i].initialize((MenuItemImpl)this.menu.getItem(i), 0);
    this.presenter.setUpdateSuspended(false);
}

// 判断是否需要偏移
private boolean isShifting(int labelVisibilityMode, int childCount) {
    return labelVisibilityMode == -1 ? childCount > 3 : labelVisibilityMode == 0;
}
```
> 说明：主要是 `isShifting` 方法中处理：当 labelVisibilityMode 为默认值 `-1` 时，菜单数目大于 `3` 个，会偏移，否则不会偏移；当 labelVisibilityMode 值为 `0` 时,会偏移；其他取值不会偏移 。

最后来看看 `BottomNavigationItemView` 中 item 偏移与 label 显示与否的相关设置：

```
// ...
switch(this.labelVisibilityMode) {
    case -1:
        if (this.isShifting) {
            if (checked) {
                this.setViewLayoutParams(this.icon, this.defaultMargin, 49);
                this.setViewValues(this.largeLabel, 1.0F, 1.0F, 0);
            } else {
                this.setViewLayoutParams(this.icon, this.defaultMargin, 17);
                this.setViewValues(this.largeLabel, 0.5F, 0.5F, 4);
            }

            this.smallLabel.setVisibility(4);
        } else if (checked) {
            this.setViewLayoutParams(this.icon, (int)((float)this.defaultMargin + this.shiftAmount), 49);
            this.setViewValues(this.largeLabel, 1.0F, 1.0F, 0);
            this.setViewValues(this.smallLabel, this.scaleUpFactor, this.scaleUpFactor, 4);
        } else {
            this.setViewLayoutParams(this.icon, this.defaultMargin, 49);
            this.setViewValues(this.largeLabel, this.scaleDownFactor, this.scaleDownFactor, 4);
            this.setViewValues(this.smallLabel, 1.0F, 1.0F, 0);
        }
        break;
    case 0:
        if (checked) {
            this.setViewLayoutParams(this.icon, this.defaultMargin, 49);
            this.setViewValues(this.largeLabel, 1.0F, 1.0F, 0);
        } else {
            this.setViewLayoutParams(this.icon, this.defaultMargin, 17);
            this.setViewValues(this.largeLabel, 0.5F, 0.5F, 4);
        }

        this.smallLabel.setVisibility(4);
        break;
    case 1:
        if (checked) {
            this.setViewLayoutParams(this.icon, (int)((float)this.defaultMargin + this.shiftAmount), 49);
            this.setViewValues(this.largeLabel, 1.0F, 1.0F, 0);
            this.setViewValues(this.smallLabel, this.scaleUpFactor, this.scaleUpFactor, 4);
        } else {
            this.setViewLayoutParams(this.icon, this.defaultMargin, 49);
            this.setViewValues(this.largeLabel, this.scaleDownFactor, this.scaleDownFactor, 4);
            this.setViewValues(this.smallLabel, 1.0F, 1.0F, 0);
        }
        break;
    case 2:
        this.setViewLayoutParams(this.icon, this.defaultMargin, 17);
        this.largeLabel.setVisibility(8);
        this.smallLabel.setVisibility(8);
    }

    this.refreshDrawableState();
    this.setSelected(checked);
}

// ...
private void setViewLayoutParams(@NonNull View view, int topMargin, int gravity) {
    LayoutParams viewParams = (LayoutParams)view.getLayoutParams();
    viewParams.topMargin = topMargin;
    viewParams.gravity = gravity;
    view.setLayoutParams(viewParams);
}

private void setViewValues(@NonNull View view, float scaleX, float scaleY, int visibility) {
    view.setScaleX(scaleX);
    view.setScaleY(scaleY);
    view.setVisibility(visibility);
}
// ...

```
由于 labelVisibilityMode 的多种取值(-1-2,设置其他值会导致切换时 label 无动画)，上面出现了多种情况，如下简要说明：

<table>
    <tr>
        <th>labelVisibilityMode 值</th>
        <th>item 个数</th>
        <th>isShifting 值</th>
        <th>代码说明</th>
    </tr>
    
    <tr>
        <td rowspan="2">auto,-1,默认</td>
        <td>4-5</td>
        <td>true</td>
        <td>选中时，显示 largeLabel，未选中时隐藏，smallLabel 一直隐藏</td>
    </tr>
    
    <tr>
        <td>1-3</td>
        <td>false</td>
        <td>选中时，显示 largeLabel，隐藏 smallLabel；未选中时相反</td>
    </tr>
    
    <tr>
        <td>selected,0</td>
        <td rowspan="3">1-5</td>
        <td>true</td>
        <td>选中时，显示 largeLabel，未选中时隐藏，smallLabel 一直隐藏</td>
    </tr>
    
    <tr>
        <td>labeled,1</td>
        <td rowspan="2">false</td>
        <td>选中时，显示 largeLabel，隐藏 smallLabel；未选中时相反</td>
    </tr>
    
    <tr>
        <td>unlabeled,2</td>
        <td>始终隐藏 largeLabel，和 largeLabel</td>
    </tr>

</table>


> 注意：(1)、由于没有源码，AS 自动生成的，代码中有些是具体的值。(2)、对于 View 的显示状态：VISIBLE 为 0、INVISIBLE 为 4、GONE 为 8 ；通过查看 `27.1.1` 中 BottomNavigationItemView 对应的源码，设置 gravity 参数分别为 : `Gravity.CENTER` , `Gravity.CENTER_HORIZONTAL | Gravity.TOP` , 值为 `17`、 `49` (通过相应的 `|` 、`<<` 运算而得，可在 [Gravity](http://androidxref.com/9.0.0_r3/xref/frameworks/base/core/java/android/view/Gravity.java) 源码中查看)。上述源码中调用 `setViewLayoutParams` 时传入的 17/49 的值应该与之前版本一致。

## 四、总结

对于 28以前，可以使用上面的工具类，来保证操作3个 tab 的显示不偏移；而 28 以后直接设置 ` app:labelVisibilityMode="labeled"` 即可。此外，对于项目中的依赖库的升级，需要了解其 api 的变更，然后作出相应的更换。另外，如果项目中自定义了 `CoordinatorLayout.Behavior`，在 28 以后，也需要注意，应为官方 删除了 `layoutDependsOn`、 `onDependentViewChanged`方法。



> **本文作者**：[imtianx](http://imtianx.cn/about)
> **本文链接**：http://imtianx.cn/2018/09/04/as3_2_pre_androix_bug
> **版权申明**:：本站文章均采用 [CC BY-NC-SA 3.0 CN](http://creativecommons.org/licenses/by-nc-sa/3.0/cn/) 许可协议，请勿用于商业，转载请注明出处！


