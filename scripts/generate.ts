import fs from 'fs';
import path from 'path';
export function isStringEnclosedWith(str: string, start: string = '`', end: string = start): boolean {
  return str.startsWith(start) && str.endsWith(end);
}

export function generate(vars: Record<string, any>, body: string): string {
  const varNames: string[] = Object.keys(vars);
  const varValues: any[] = Object.values(vars);
  let fnBody: string = body.trim();
  if (!isStringEnclosedWith(body)) {
    fnBody = '`' + body + '`';
  }
  const template = new Function(...varNames, `return ${fnBody}`);
  return template(...varValues);
}

export function generateFromFile(vars: Record<string, any>, filePath: string): string {
  if (!fs.existsSync(filePath)) {
    throw new Error(`File ${filePath} does not exist`);
  }
  return generate(vars, fs.readFileSync(filePath, 'utf-8'));
}

type TemplateVars = {
  protocolName: string;
  contractName: string;
  networkName: string;
  [key: string]: any;
};

type GenerateTemplateOptions = {
  templateName: string;
  templatesPath: string;
  contractsPath: string;
  testsPath: string;
  vars: TemplateVars;
  overwrite?: boolean;
};

export function generateAnteTestFromTemplate(options: GenerateTemplateOptions): boolean {
  const templatePath = path.join(options.templatesPath, options.templateName);
  if (!fs.existsSync(templatePath)) {
    throw new Error(`Template ${options.templateName} does not exist`);
  }

  if (!fs.existsSync(options.contractsPath)) {
    throw new Error(`Contracts path ${options.contractsPath} does not exist`);
  }

  if (!fs.existsSync(options.testsPath)) {
    throw new Error(`Tests path ${options.testsPath} does not exist`);
  }

  const contractTemplatePath = path.join(options.templatesPath, options.templateName, './contract.ante-template');
  const testTemplatePath = path.join(options.templatesPath, options.templateName, './test.ante-template');

  const contractBody = generateFromFile(options.vars, contractTemplatePath);
  const testBody = generateFromFile(options.vars, testTemplatePath);

  const contractPath = path.join(
    options.contractsPath,
    options.vars.protocolName.toLowerCase(),
    options.vars.contractName +
      `_${options.vars.protocolName.toLowerCase()}_${options.vars.networkName.toLowerCase()}.sol`
  );
  if (fs.existsSync(contractPath) && !options.overwrite) {
    throw new Error(`Contract ${contractPath} already exists`);
  }

  const testPath = path.join(
    options.testsPath,
    options.vars.protocolName.toLowerCase(),
    options.vars.contractName +
      `_${options.vars.protocolName.toLowerCase()}_${options.vars.networkName.toLowerCase()}.spec.ts`
  );
  if (fs.existsSync(testPath) && !options.overwrite) {
    throw new Error(`Test ${testPath} already exists`);
  }
  if (!fs.existsSync(path.dirname(contractPath))) {
    fs.mkdirSync(path.dirname(contractPath), { recursive: true });
  }
  if (!fs.existsSync(path.dirname(testPath))) {
    fs.mkdirSync(path.dirname(testPath), { recursive: true });
  }

  fs.writeFileSync(contractPath, contractBody);
  fs.writeFileSync(testPath, testBody);
  return true;
}

type GenerateAnteTestsOptions = {
  templatesPath: string;
  contractsPath: string;
  testsPath: string;
  overwrite?: boolean;
};

type GenerateAnteTest = {
  templateName: string;
  vars: TemplateVars;
};

export function generateAnteTests(anteTests: GenerateAnteTest[], options: GenerateAnteTestsOptions) {
  for (const anteTest of anteTests) {
    generateAnteTestFromTemplate({
      ...options,
      templateName: anteTest.templateName,
      vars: anteTest.vars,
    });
  }
}

const generateFromConfigFile = (configFilePath: string) => {
  const generatAnteTestsOptions: GenerateAnteTestsOptions = {
    templatesPath: path.join(__dirname, '../templates'),
    contractsPath: path.join(__dirname, '../contracts'),
    testsPath: path.join(__dirname, '../test'),
    overwrite: true,
  };

  const toBeGenerated = JSON.parse(fs.readFileSync(configFilePath, 'utf-8'));

  const anteTests: GenerateAnteTest[] = toBeGenerated;

  generateAnteTests(anteTests, generatAnteTestsOptions);
};

if (process.argv.length > 2) {
  generateFromConfigFile(process.argv[2]);
}
