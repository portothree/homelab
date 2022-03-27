# homelab

```mermaid
graph TD
	subgraph Main PC
		A[Proxmox VE] -->|192.168.1.106| 100{VM - NixOS};
		100 -->|:22| 100_ssh[OpenSSH];
		100 -->|:6443 :80| K3s[K3s Kubernetes distribution];
		K3s -->|192.168.1.100-192.168.1.250| MetalLB(MetalLB in layer 2 mode);
		click MetalLB "https://metallb.org/concepts/layer2" _blank
		K3s -->|:80| Kong(Kong Ingress controller);
		K3s --> Pi-hole(Pi-hole instance);
		Kong -->|pi.hole| Pi-hole;
		
		A -->|192.158.1.103| 102{VM - Debian};
		102 -->|:22| 102_ssh[OpenSSH];
		102 --> lolminer[LolMiner ETH/TON with 3060 Ti];
		
		A -->|192.158.1.104| 103{VM - NixOS};
		103 -->|:22| 103_ssh[OpenSSH];
		
		A -->|192.168.1.105| 104{VM - NixOS};
		104 -->|:22| 104_ssh[OpenSSH];
	end
	
	classDef orange fill:#f96;
	class A orange
```

Diagram/flowchart using [mermaid](https://github.com/mermaid-js/mermaid)

## Resources

- https://github.com/0dragosh/homelab-k3s
- https://github.com/TUM-DSE/doctor-cluster-config/tree/master/modules/k3s
- https://github.com/fluxcd/flux2-kustomize-helm-example
