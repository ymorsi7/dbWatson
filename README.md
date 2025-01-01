# DBWatson

A practical extension to DBSherlock that adds GPT-4 capabilities for better anomaly detection

## About

Building on the DBSherlock project from UMich (original repo is [here](https://github.com/dongyoungy/dbsherlock-reproducibility)) and linked it to GPT-4. The original tool was already great at identifying performance issues in databases, we were able to improve it by connecting it to GPT-4.

## What's new?

We added three main things:
- The system now learns from past incidents (not just raw stats)
- Better rules for catching problems (by combining DBSherlock's statistical approach with GPT-4's insights)
- Plain English explanations of what went wrong (rather than data dumps)

## Results

### Original DBSherlock
Here's what the original could do (these graphs are from the UMich paper):

![Original Analysis](figure1.png)
*Accuracy of Single Causal Models*

![Original Analysis](figure2.jpg)
*DBSherlock Predicates vs PerfXplain*

![Original Analysis](figure3.jpg)
*Merged Causal Models Effectiveness*

![Original Analysis](figure4.jpg)
*Merged Causal Models Effectiveness*

![Original Analysis](figure5.jpg)
*Merged Causal Models Effectiveness*

![Original Analysis](figure6.jpg)
*Explaining Compound Situations*

![Original Analysis](figure7.jpg)
*Effect of Incorporating Domain Knowledge*


### Improvements
After adding GPT-4 to the mix, we saw:
- Improved confidence scores and F-scores in anomaly detection
- Enhanced pattern recognition capabilities
- More accurate root cause analysis

![LLM Performance Metrics](figureLLM.png)
*Distribution of Confidence Scores and F-scores with LLM Enhancement*

## Setting Up

### Software:
- MATLAB R2015b or newer (yeah, we know, but it's what DBSherlock uses)
- OpenAI API key

### Setup

1. Grab the code:
```bash
git clone https://github.com/ymorsi7/db-watson.git
cd db-watson
```

2. Set up your API key:
```bash
export OPENAI_API_KEY='your-key-here'
```

3. Get the data:
- Grab the original DBSherlock datasets from their repo
- Put them in `data/dbsherlock/`
- Our extended datasets go in `data/db-watson/`

## Running Code:

```bash
cd experiments/dbsherlock
matlab -nodisplay -nosplash -nodesktop -r "run_baseline_experiments"
```


## Credit:

This is built on top of DBSherlock by DongYoung Yoon, Ning Niu, and Barzan Mozafari from the University of Michigan. If you use this for research, please cite their original paper:

```bibtex
@inproceedings{yoon2016dbsherlock,
  title={DBSherlock: A Performance Diagnostic Tool for Transactional Databases},
  author={Yoon, DongYoung and Niu, Ning and Mozafari, Barzan},
  booktitle={Proceedings of the 2016 International Conference on Management of Data},
  year={2016},
  organization={ACM}
}
```
