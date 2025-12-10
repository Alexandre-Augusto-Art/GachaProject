// generate_items.js
const fs = require('fs');
const path = require('path');

const itemsDir = path.join(__dirname, 'assets', 'items');
const outputFile = path.join(__dirname, 'items_data.js');

const categories = {
    'Grande premio': 'grand',
    'Premio medio': 'medium',
    'Premio basico': 'basic'
};

const database = {
    grand: [],
    medium: [],
    basic: []
};

function formatName(filename) {
    // Remove extensão
    let name = path.parse(filename).name;
    // Remove prefixos comuns se existirem (ex: Poster_A3_, Sticker_, Botton_)
    name = name.replace(/^(Poster_A3_|Sticker_|Botton_|Group \d+ - )/i, '');
    // Substitui underscores por espaços
    name = name.replace(/_/g, ' ');
    // Adiciona espaços antes de letras maiúsculas (CamelCase -> Camel Case) se não houver espaço
    name = name.replace(/([a-z])([A-Z])/g, '$1 $2');
    return name.trim();
}

function scanDirectory() {
    console.log('Varrendo diretórios...');
    
    if (!fs.existsSync(itemsDir)) {
        console.error(`Diretório não encontrado: ${itemsDir}`);
        return;
    }

    Object.keys(categories).forEach(dirName => {
        const dirPath = path.join(itemsDir, dirName);
        const type = categories[dirName];
        
        if (fs.existsSync(dirPath)) {
            const files = fs.readdirSync(dirPath);
            
            files.forEach(file => {
                if (file.match(/\.(png|jpg|jpeg|gif|webp)$/i)) {
                    // Caminho relativo para uso no HTML (substituindo \ por / para compatibilidade web)
                    const webPath = `assets/items/${dirName}/${file}`.replace(/\\/g, '/');
                    
                    database[type].push({
                        name: formatName(file),
                        img: webPath
                    });
                }
            });
            console.log(`Categoria '${type}': ${database[type].length} itens encontrados.`);
        } else {
            console.warn(`Pasta de categoria não encontrada: ${dirName}`);
        }
    });

    const content = `const ITEM_DATABASE = ${JSON.stringify(database, null, 4)};`;
    
    fs.writeFileSync(outputFile, content);
    console.log(`Arquivo gerado com sucesso: ${outputFile}`);
}

scanDirectory();


