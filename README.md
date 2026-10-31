# PCSX2 com Suporte a GPU no Docker

Este documento explica como rodar o emulador PCSX2 via Docker e como a aceleração de hardware e o acesso à placa de vídeo (GPU) estão configurados no ambiente.

## ⚠️ O que rodar no terminal antes de iniciar

Como o emulador precisa abrir uma janela e usar a placa de vídeo através do X11 (o servidor gráfico do seu Linux), você precisa "liberar" a permissão de vídeo no terminal **antes** de subir o contêiner. 

**1. Libere o acesso ao seu display rodando:**
```bash
xhost +local:docker
```


**2. Inicie o emulador:**
```bash
docker compose up -d --build
```

*(Opcional) Quando terminar de jogar, você pode revogar a permissão por segurança rodando:*
```bash
xhost -local:docker
```

---

## Como a Placa de Vídeo é Liberada no Docker-Compose?

Para que o emulador dentro do contêiner consiga se comunicar com a placa de vídeo do host (sua máquina física) com desempenho máximo, utilizamos três abordagens simultâneas no `docker-compose.yml`:

### 1. Suporte a NVIDIA (NVIDIA Container Toolkit)

Se você estiver utilizando uma placa de vídeo da NVIDIA, o contêiner solicita acesso direto a ela através do bloco `deploy`:

```yaml
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu, graphics, display]
```

* **O que faz:** Informa ao Docker para reservar 1 GPU da NVIDIA e repassar os recursos gráficos e de display para o contêiner.
* **Variáveis de Ambiente Mapeadas:** 
  * `NVIDIA_DRIVER_CAPABILITIES=all`
  * `NVIDIA_VISIBLE_DEVICES=all`
* **Requisito:** É obrigatório ter o [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) instalado no seu sistema.

### 2. Suporte a AMD/Intel (Mesa/DRI)

Se você utiliza gráficos integrados da Intel ou uma placa de vídeo da AMD, a comunicação não é feita pelo bloco da Nvidia, mas sim pelo mapeamento direto do driver no sistema de arquivos do Linux:

```yaml
    volumes:
      - /dev/dri:/dev/dri:rw
```

* **O que faz:** O diretório `/dev/dri` (Direct Rendering Infrastructure) é onde o Linux se comunica diretamente com o hardware de vídeo. Ao passar esse volume como `rw` (leitura e escrita), o contêiner tem acesso de baixo nível à GPU AMD/Intel.

### 3. API Gráfica (Vulkan / OpenGL)

Para garantir que as APIs gráficas mais modernas (como o Vulkan, muito recomendado para o PCSX2) funcionem, foram feitas as seguintes configurações:

* **Mapeamento de ICDs:** O volume `/usr/share/vulkan/icd.d:/usr/share/vulkan/icd.d:ro` garante que o contêiner saiba onde encontrar os drivers Vulkan instalados no sistema host.
* **Bibliotecas no Dockerfile:** O `Dockerfile` já instala pacotes cruciais como `libvulkan1`, `mesa-vulkan-drivers`, `libgl1` e `libopengl0`.
* **Mapeamento do Display (X11):** O volume `/tmp/.X11-unix:/tmp/.X11-unix:rw` é o que permite a janela do jogo aparecer na sua tela (e é por causa dele que você precisa rodar o comando `xhost` antes).

---

## Recomendações para o GitHub (Aviso de Copyright)

Se for compartilhar este projeto no GitHub, crie um arquivo `.gitignore` na raiz do projeto com o seguinte conteúdo para evitar problemas legais (DMCA) com a Sony:

```gitignore
# Ignorar arquivos do Emulador
*.AppImage

# Ignorar pastas de Jogos e BIOS (Copyright)
biblioteca_jogos/
pcsx2_config/
```

**Nunca** versione as BIOS (`.bin`, `.mec`, etc) ou ROMs/ISOs dos jogos em repositórios públicos.