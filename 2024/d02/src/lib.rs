use std::any;
use std::fs::File;
use std::io::{self, BufRead, BufReader};

fn read_levels(path: &str) -> io::Result<Vec<Vec<i64>>> {
    let f = File::open(path)?;
    let reader = BufReader::new(f);
    let mut records = Vec::new();

    for line in reader.lines() {
        let line = line?;
        let line = line.trim();
        if line.is_empty() { continue; }

        let nums: Result<Vec<i64>, _> = line
            .split_whitespace()
            .map(|s| s.parse::<i64>().map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e)))
            .collect();

        records.push(nums?);
    }

    Ok(records)
}


fn is_safe_level(level: &[i64]) -> bool {
    if level.len() < 2 {
        return false;
    }
    let r_diff: Vec<i64> = level.windows(2).map(|s| s[1] - s[0]).collect();
    //println!("  r_diff = {:?}", &r_diff);
    let all_pos = r_diff.iter().all(|&x| x > 0);
    let all_neg = r_diff.iter().all(|&x| x < 0);
    let good_range = r_diff.iter().all(|&x| x.abs() >= 1 && x.abs() <= 3);
    (all_pos || all_neg) && good_range
}


#[test]
fn part1() {
    //let sample = "7 6 4 2 1\n1 2 7 8 9\n9 7 6 2 1\n1 3 2 4 5\n8 6 4 4 1\n1 3 6 7 9";
    //std::fs::write("test_input.txt", sample).expect("write sample input");
    let levels = read_levels("../input/02").unwrap();
    println!("Read {} records", levels.len());
    let mut counter = 1;
    for record in &levels {
        //println!("{:?}", &record);
        if is_safe_level(record) {
            println!("({})  safe: {:?}", counter, &record);
        }
        counter += 1;
    }
    let safe_count = levels.iter().filter(|level| is_safe_level(level)).count();
    println!("Number of safe levels: {}", safe_count);
}

fn all_leave_one_out(xs: &[i64]) -> Vec<Vec<i64>> {
    let n = xs.len();
    let mut out = Vec::with_capacity(n);
    for i in 0..n {
        let mut v = Vec::with_capacity(n.saturating_sub(1));
        v.extend_from_slice(&xs[..i]);
        v.extend_from_slice(&xs[i+1..]);
        out.push(v);
    }
    out
}


#[test]
fn part2() {
    //let sample = "7 6 4 2 1\n1 2 7 8 9\n9 7 6 2 1\n1 3 2 4 5\n8 6 4 4 1\n1 3 6 7 9";
    //std::fs::write("test_input.txt", sample).expect("write sample input");
    let levels = read_levels("../input/02").unwrap();
    println!("Read {} records", levels.len());
    let mut safe = 0;
    for record in &levels {
        // store the variations in a local variable
        let variations = all_leave_one_out(record);

        let leave_one_out_safe: Vec<bool> = variations
            .iter()
            .map(|v| is_safe_level(v)) // `v: &Vec<i64>` coerces to `&[i64]`
            .collect();
        let any_safe = leave_one_out_safe.iter().cloned().any(|b| b);
        //println!("  safe variations: {:?} > {:?}", &leave_one_out_safe, any_safe);
        if any_safe {
            safe += 1;
        }
        
    }
    println!("Number of safe levels: {}", safe);
}