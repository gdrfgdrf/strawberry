const parser = require('@babel/parser');
const traverse = require('@babel/traverse').default;
const t = require('@babel/types');
const generate = require('@babel/generator').default;
const fs = require('fs');

function extractArrays(ast) {
    const arrays = { a: [], b: [], c: [], x: [] };

    traverse(ast, {
        VariableDeclarator(path) {
            const id = path.node.id;
            if (t.isIdentifier(id) && arrays.hasOwnProperty(id.name)) {
                const init = path.node.init;
                if (t.isArrayExpression(init)) {
                    arrays[id.name] = init.elements.map(element => {
                        if (t.isNumericLiteral(element)) {
                            return element.value;
                        }
                        if (t.isUnaryExpression(element) &&
                            element.operator === '-' &&
                            t.isNumericLiteral(element.argument)) {
                            return -element.argument.value;
                        }
                        if (t.isStringLiteral(element)) {
                            return element.value;
                        }
                        return null;
                    });
                }
            }
        }
    });

    return arrays;
}

function replaceArrayAccesses(ast, arrays) {
    const bindings = {};
    traverse(ast, {
        VariableDeclarator(path) {
            const id = path.node.id;
            if (t.isIdentifier(id)) {
                bindings[id.name] = path;
            }
        }
    });

    traverse(ast, {
        MemberExpression(path) {
            const object = path.node.object;
            const property = path.node.property;

            if (!t.isIdentifier(object) || !arrays[object.name]) {
                return;
            }

            const arrayName = object.name;
            const array = arrays[arrayName];

            let indexValue;

            if (t.isNumericLiteral(property)) {
                indexValue = property.value;
            }
            else if (t.isIdentifier(property)) {
                const binding = bindings[property.name];
                if (binding &&
                    t.isVariableDeclarator(binding.node) &&
                    t.isNumericLiteral(binding.node.init)) {
                    indexValue = binding.node.init.value;
                }
            }
            else if (t.isUnaryExpression(property) &&
                property.operator === '-' &&
                t.isNumericLiteral(property.argument)) {
                indexValue = -property.argument.value;
            }

            if (Number.isInteger(indexValue) &&
                indexValue >= 0 &&
                indexValue < array.length) {

                const value = array[indexValue];
                let newNode;

                if (arrayName === 'a') {
                    newNode = t.numericLiteral(value);
                } else {
                    newNode = t.stringLiteral(value);
                }

                path.replaceWith(newNode);
            }
        }
    });
}

function processFile(inputPath, outputPath) {
    const code = fs.readFileSync(inputPath, 'utf-8');
    const ast = parser.parse(code, {
        sourceType: 'script',
        plugins: ['numericSeparator']
    });

    const arrays = extractArrays(ast);
    replaceArrayAccesses(ast, arrays);

    const output = generate(ast, {
        retainLines: true,
        comments: true,
        compact: false
    }).code;

    fs.writeFileSync(outputPath, output);
}

processFile('checkToken.js', 'checkToken_processed.js');