# pcsx2-docker

Um ambiente Docker pronto para rodar o emulador PCSX2 de forma isolada no Linux, com suporte a renderização via GPU (NVIDIA/Vulkan), áudio e controles USB nativos. O processo de build, baixar e configurar o AppImage do emulador é feito automaticamente.

## 🚀 Como Usar (Passo a Passo)

A configuração foi desenhada para ser *plug and play*. Siga os passos abaixo:

**1. Prepare seus arquivos (BIOS e Jogos)**
* Coloque o arquivo da sua BIOS do PS2 (ex: `bios_ps2.bin`) na mesma pasta onde está o arquivo `docker-compose.yml`.
* Coloque suas ISOs de jogos na pasta `ps2_games`.

**2. Libere o acesso de vídeo (X11)**
Como o emulador precisa abrir uma janela e usar a placa de vídeo, você precisa liberar a permissão no terminal **antes** de subir o contêiner:
```bash
xhost +local:docker
```

**3. Inicie o contêiner**
```bash
docker compose up -d --build
```
*O Docker fará o download do emulador automaticamente e subirá o ambiente.*

**4. Assistente de Configuração do PCSX2**
Ao abrir a janela de boas-vindas do emulador, avance até as seguintes etapas:
* **BIOS:** O arquivo que você colocou na raiz do projeto estará mapeado automaticamente no diretório `/root/bios`. Basta selecioná-lo na lista.
* **Diretórios de Jogos:** Adicione o diretório onde os jogos estão mapeados (como `/root/bios/ps2_games` e marque para escanear recursivamente.

Pronto! Seus jogos aparecerão na lista e você já pode jogar clássicos como God of War II com alta resolução e API Vulkan.

*(Opcional) Quando terminar de jogar, você pode revogar a permissão do display rodando:*
```bash
xhost -local:docker
```

---

## 🛠️ Como a Placa de Vídeo é Liberada no Docker-Compose?

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
* **Requisito:** É obrigatório ter o [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) instalado e configurado no seu sistema.

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

## ⚠️ Recomendações de Copyright (GitHub)

**NUNCA** versione as BIOS (`.bin`, `.mec`, etc) ou ROMs/ISOs dos jogos em repositórios públicos. 

Para evitar problemas legais (DMCA), certifique-se de que o repositório tenha um arquivo `.gitignore` ignorando esses itens, por exemplo:

```gitignore
# Ignorar arquivos do Emulador
*.AppImage

# Ignorar arquivos de BIOS e Jogos
*.bin
*.iso
*.gz
ps2_games/
```