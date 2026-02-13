

const cuboidAttributes = function (length, width, height) {
  let attribs = {
    surfaceArea: 0,
    volume: 0
  }

  attribs.surfaceArea = (length * width + width * height + length * height) * 2;
  attribs.volume = length * width * height;

  return attribs;
}

console.log(`Volume is ${cuboidAttributes(2, 10, 3).volume}`);
console.log(`Surface Area is ${cuboidAttributes(2, 10, 3).surfaceArea}`);

