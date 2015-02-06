package com.tilfin.adc.echo{
	
    import flash.net.IPVersion;
    import flash.net.InterfaceAddress;
    import flash.net.NetworkInfo;
    import flash.net.NetworkInterface;

	//サーバーのバインダブルなIPアドレス(IPv4)をリスト取得 Arrayで返す
    public class InterfaceUtil
    {
        private static var bindableAddressesCache:Array;
        
        public static function getBindableAddresses():Array
        {
            if (bindableAddressesCache) return bindableAddressesCache;
            
            var addresses:Array = new Array();
            var netinfo:NetworkInfo = NetworkInfo.networkInfo;
            var netifs:Vector.<NetworkInterface> = netinfo.findInterfaces();
            
            for each (var netif:NetworkInterface in netifs)
            {
                for each (var addr:InterfaceAddress in netif.addresses)
                {
                    if (addr.ipVersion == IPVersion.IPV4) {
                        addresses.push(addr.address);
                    }
                }
            }
            
            bindableAddressesCache = addresses;
            return addresses;
        }
    }
}