%{ for key,name in names_list ~}
${key+1}: ${route53_records_list[name].fqdn} ${droplets_list[name].ipv4_address} ${passwords[name].result}
%{ endfor ~}
