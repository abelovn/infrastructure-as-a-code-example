## Создание Active Directory (Domain Controller) в Yandex Cloud с помощью terraform and ansible.

В этом примере происходит создание серверов в Yandex Cloud c помощью terraform.


### Установите yandexcloud cli
```
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

### Инициализируйте yandexcloud cli
```
yc init
```

### Получите token, cloud-id, folder-id
```
yc config list
```
Output:
```
token: xxx
cloud-id: xxx
folder-id: xxxx
compute-default-zone: ru-central1-c
```

### Создайте private.auto.tfvars из примера private.auto.tfvars.example
Скопируйте или переименуйте private.auto.tfvars.example в private.auto.tfvars, заполните yc_token,
yc_cloud_id, yc_folder_id.

Укажите yc_zone - avalability zone по умолчанию.

Укажите windows_password как пароль локального Administrator Windows. 

Укажите hostname как имя сервера.

Укажите название домена pdc_domain, например "ad.domain.test".

Укажите pdc_domain_path, например "dc=ad,dc=domain,dc=test".

Links:
 - https://gist.github.com/jugatsu/e9e09db6c7cba6900fce2d275dba515f
 - https://github.com/justin-p/ansible-role-pdc/issues/4
 - https://nikolaymatrosov.medium.com/rdp-%D0%BD%D0%B0-ubuntu-%D0%B2-yandex-cloud-c9d7870a47cc
 - https://yetiops.net/posts/proxmox-terraform-cloudinit-windows/
 - https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1
 - https://stackoverflow.com/questions/42871257/download-a-file-using-invoke-webrequest-in-powershell-by-calling-a-ps1-file-us
 - https://stackoverflow.com/questions/62224835/terraform-file-provisioner-to-upload-to-azure-vm-using-winrm-error-i-o-timeout
 - https://jpcodeqa.com/q/b54bc187845da53942452666fc059ec5
 - https://stackoverflow.com/questions/65873952/terraform-file-provisioner