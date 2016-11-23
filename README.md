本工程为基于高德地图iOS 导航SDK进行封装，实现了Apple Watch上导航信息的展示。
## 前述 ##
- [高德官网申请Key](http://lbs.amap.com/dev/#/).
- 阅读[开发指南](http://lbs.amap.com/api/ios-navi-sdk/summary/).
- 工程基于iOS 3D地图SDK和导航SDK实现.

## 功能描述 ##
通过导航SDK进行路径规划和导航，将导航信息发送到Apple Watch端进行展示。

## 核心类/接口 ##
| 类    | 接口  | 说明   | 版本  |
| -----|:-----:|:-----:|:-----:|
| AMapNaviDriveManager	| - (BOOL)calculateDriveRouteWithEndPoints:(NSArray<AMapNaviPoint *> *)endPoints wayPoints:(nullable NSArray<AMapNaviPoint *> *)wayPoints drivingStrategy:(AMapNaviDrivingStrategy)strategy; | 不带起点的驾车路径规划 | v2.0.0 |
| AMapNaviDriveDataRepresentable	| - (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviInfo:(nullable AMapNaviInfo *)naviInfo; | 导航诱导信息回调方法 | v2.0.0 |

## 核心难点 ##

## 注意：
AppleWatch Demo 可直接在模拟器上运行，如需在真机运行，需要您登录 Apple 开发者中心，创建您自己的 AppGroup，并获取具有 AppGroup 权限的证书。

```
/* 导航诱导信息回调. */
- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviInfo:(AMapNaviInfo *)naviInfo
{
    _savedNaviInfo = naviInfo;
    
    //将导航诱导信息发送到Apple Watch端
    [self sendNaviInfoMessage];
}
```
