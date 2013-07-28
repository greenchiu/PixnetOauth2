PixnetOauth2
============

提供PixnetOauth2的方法, 目前只支援`json`格式.

## 安裝

將pixnetclasses的class加入你的專案
需要使用到[JSONKit](https://github.com/johnezang/JSONKit)來處理回傳json的部份

## 使用

import `PixnetOauth2` and `PixnetOauth2ViewController`

```Objective-C
typeof(self) __weak w_self = self;
PixnetOauth2CompletedHandler handler = ^(PixnetOauth2* oauth, BOOL isCancel, NSError* error) {
  if(oauth) {
    // oauth中包含accessToken&refreshToken.
  } else if(isCancel || error) {
    /**
     * isCancel = YES, 表示自行退出Oauth流程
     * error, 錯誤訊息
     */
  }
};
    
PixnetOauth2ViewController* pnoController;
pnoController = [[PixnetOauth2ViewController alloc] initOauthWithClientId:consumer_key
                                                             clientSecret:consumer_sercet
                                                              redirectUrl:redirect_uri
                                                         completedHandler:handler];
[self presentViewController:pnoController animated:YES completion:^{}];
```

## 參考來源

* [PIXNET Developers](http://apps.pixnet.tw/)

## Notes

* 2013/07/28

 
> 增加SDK版本(current 0.1000),   
> 同時將`PixnetOauth2ViewController`的 grant authorization_code action 調整到 `PixnetOauth2`,  
> 並定義`PixnetOauth2GrantType`以及`GrantCompletedHandler`, 加上部分NSError的定義 
>

## License

Copyright (c) 2013 Green Chiu, http://greenchiu.github.com/ Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
