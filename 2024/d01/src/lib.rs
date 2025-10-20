use std::fs::File;
use std::io::{self, BufRead, BufReader};
use std::collections::HashMap;

pub fn read_pairs(path: &str) -> io::Result<Vec<(i64, i64)>> {
    let f = File::open(path)?;
    let reader = BufReader::new(f);
    let mut pairs = Vec::new();

    for line in reader.lines() {
        let line = line?;
        let line = line.trim();
        if line.is_empty() { continue; }

        let mut it = line.split_whitespace();
        let a_str = it.next().ok_or_else(|| io::Error::new(io::ErrorKind::InvalidData, "missing first number"))?;
        let b_str = it.next().ok_or_else(|| io::Error::new(io::ErrorKind::InvalidData, "missing second number"))?;

        let a = a_str.parse::<i64>().map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;
        let b = b_str.parse::<i64>().map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;
        pairs.push((a, b));
    }

    Ok(pairs)
}

#[test]
fn d01_part1() {
    let pairs = read_pairs("../input/01").expect("read input");
   
    for (a, b) in &pairs {
        println!("a = {}, b = {}", a, b);
    }
    println!("Number of pairs: {}", pairs.len());
    // sort a and b separately
    let mut a_vals: Vec<i64> = pairs.iter().map(|(a, _)| *a).collect();
    a_vals.sort();
    let mut b_vals: Vec<i64> = pairs.iter().map(|(_, b)| *b).collect();
    b_vals.sort();
    for i in 0..a_vals.len() {
        println!("a sort = {}, b sort = {}", a_vals[i], b_vals[i]);
    }
    let sum_abs_diff: i64 =  a_vals.iter()
    .zip(b_vals.iter())
    .map(|(x,y)| (*x - *y).abs())
    .sum();
    println!("sum diff = {:?}", sum_abs_diff);
}

#[test]
fn d01_part2() {
    let pairs = read_pairs("../input/01").expect("read input");
    let mut map: HashMap<i64, Vec<i64>> = HashMap::new();
    // initialize to zeroes with keys from a values
    for (a, _) in &pairs {
        map.entry(*a).or_default().push(0);
    }
    for (_, b) in &pairs {
        if map.contains_key(b) {
            map.entry(*b).or_default().push(1);
        }
    }

    println!("map len = {}", map.len());
    let mut sum: i64 = 0;
    for (k, v) in &map {
        sum += k * v.iter().sum::<i64>();
        //println!("{} -> {:?} ({})", k, v, sum);
    }
    println!("final sum = {}", sum);
}

