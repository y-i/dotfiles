#!/bin/bash

# Install starship
curl -sS https://starship.rs/install.sh | sh

# Install mise
curl https://mise.run | sh

# link
$(cd $(dirname $0); pwd)/link.sh
