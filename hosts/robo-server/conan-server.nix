{ ... }:

{
  virtualisation.oci-containers = {
    backend = "docker"; 
    containers = {
      conan_server = {
        image = "conanio/conan_server:latest";
        ports = [ "9300:9300" ];
        volumes = [ "/var/conan:/root/.conan_server" ];
      };
    };
  };
}
