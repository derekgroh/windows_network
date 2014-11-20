#
# Cookbook Name:: windows_network
# Recipe:: default
#
# License: Apache license 2
#
# Authors
# Christoffer Järnåker, Proxmea BV, 2014
# Christoffer Järnåker, Schuberg Philis, 2014
#

def getnetcount2(hostname)  
        hostname = node["hostname"].downcase
        return nil if !validate_databagitem($databag_name, hostname)
        datab = data_bag_item( $databag_name, hostname)
        datai = datab['net']
        if datai == nil  
                return 0
        end 
        return datai.count
end

def getnet2(macaddress,hostname,getfirst="false") 
        macaddress = macaddress.downcase 
        hostname = node["hostname"].downcase
        return nil if !validate_databagitem($databag_name, hostname)
        datab = data_bag_item( $databag_name, hostname)
        datai = datab['net'] 
        if datai == nil  
                return nil
        end 
        datai.each do | name, mac|  
                if mac == macaddress || getfirst == "true" 
                        # We'll reset the found ip/mask so that we know we're dealing with a fresh pair 
                        $dt2ip = nil                
                        $dt2netmask = nil 
                        return name
                end
        end 
        return nil
end

def getnetname2(macaddress,hostname,getfirst="false") 
        macaddress = macaddress.downcase 
        hostname = node["hostname"].downcase 
        return nil if !validate_databagitem($databag_name, hostname)
        datab = data_bag_item( $databag_name, hostname)
        datai = datab['naming'] 
        if datai == nil  
                return nil
        end 
        datai.each do | name, mac|  
                if mac == macaddress || getfirst == "true" 
                        return name
                end
        end 
        return nil
end

def getval2(group,item,hostname) 

        # We'll implement some pickup locgic, as this datatype is quiet different from #2.
        case group
                when "address"
                        group = "ip" 
                when "netmask"
                        group = "netmasks" 
                when "dns-nameservers"
                        dns = Array.new
                        dns[0] = getval2("dns","dns1",hostname) 
                        dns[1] = getval2("dns","dns2",hostname)
                        return dns.join(',') 
                when "gateway"
                        #This will only work if ip/mask has been asked for this nic prior to this statement 
                        if !defined?($dt2ip).nil? && !defined?($dt2netmask).nil? 
                                return nil if !$dt2ip.IPAddr? || !$dt2netmask.IPAddr?
                                datab = data_bag_item( $databag_name, hostname) 
                                dfgw = datab['def_gw']  
                                net = IPAddr.new("#{$dt2ip}/#{$dt2netmask}") 
                                if net===dfgw 
                                        return dfgw
                                else 
                                        return nil
                                end
                        end
        end

        return nil if !validate_databagitem($databag_name, hostname)
        datab = data_bag_item( $databag_name, hostname) 
        datai = datab[group]
        if datai == nil  
                return nil
        end 
        datai.each do | itemname, value| 
                if itemname == item 
                        case group
                                when "ip"
                                        $dt2ip = value 
                                when "netmasks"
                                        $dt2netmask = value 
                        end
                        return value
                end
        end   
        return nil
end 