// This paper is written in Typst
// Install with `brew install typst`
// Edit and preview with the `tynimist` vscode extension
// Set `tynimist.formatterMode` to `typstfmt` to format the code

#import "@preview/charged-ieee:0.1.3": ieee
#show: ieee.with(
  title: [Benchmarking Workflow for Generative AI Systems],
  abstract: [
    This paper presents a comprehensive benchmark workflow pipeline for evaluating generative AI (GenAI) systems, from
    ground truth data creation through performance benchmarking to regression testing and continuous monitoring. The
    workflow helps data scientists systematically assess both structured and unstructured tasks, bridging the gap between AI
    capability and reliable enterprise deployment.

    We outline methodologies for statistically robust evaluation, including sample size estimation and confidence interval
    calculations to ensure reliable results. We detail specific evaluation metrics and criteria for GenAI outputs. The paper
    also describes a technical infrastructure that operationalizes the benchmarking pipeline.

    We demonstrate the workflow through two scenarios: (1) a structured document processing task extracting and validating
    information from address change forms, and (2) an unstructured chatbot task evaluating a QA chatbot augmented with
    document retrieval. For each scenario, we show how the benchmark pipeline measures model performance, upholds
    responsible AI principles, and detects regressions using domain-specific ground truth.

    The benchmark results provide insights into model strengths and weaknesses, guiding iterative improvements. We discuss
    limitations and propose future directions such as finer-grained section-level evaluations, automatic generation of test
    assertions using GenAI, and continuous feedback loops to keep benchmarks aligned with business needs.
  ],
  authors: ((
    name: "Romain Martinez",
    // department: [Co-Founder],
    organization: [Manulife Financial Corporation],
    location: [Montreal, Canada],
    email: "romain_martinez@manulife.ca",
  ), (
    name: "Other author",
    // department: [Co-Founder],
    organization: [Manulife Financial Corporation],
    location: [Toronto, Canada],
    email: "mail@manulife.ca",
  ), (
    name: "Sabya Mukherjee",
    // department: [Co-Founder],
    organization: [Manulife Financial Corporation],
    location: [Waterloo, Canada],
    email: "sabyasachi_mukherjee@manulife.ca",
  ),),
  index-terms: ("Generative AI", "AI Benchmarking", "AI Reliability", "Human Feedback", "Statistical Validation"),
  bibliography: bibliography("refs.bib", style: "apa"),
  figure-supplement: [Fig.],
)

= Introduction

== Motivation
Generative AI models have rapidly become a transformative force across industries. These systems cost tens to hundreds
of millions of dollars to develop. While they perform well in general-purpose settings and demonstrate capability, they
often struggle when applied to enterprise-specific contexts, showing poor reliability. This distinction between
capability—what GenAI could do—and reliability—what it consistently does in a business process—is crucial
@kim2024generative @wang2025assessing @theis2016note.

The gap stems from two fundamental challenges. First, the stochastic nature of generative models means the same input
can yield different outputs @kim2024generative @wang2025assessing. Second, these models lack exposure to private,
domain-specific enterprise data during pretraining. These limitations can cause significant failures, customer friction,
compliance risks, and reputational damage.

To address these issues, organizations need a robust benchmarking workflow. Such a framework ensures AI systems meet
desired performance, reliability, and quality standards despite their non-deterministic nature @theis2016note.

== Importance of Benchmarking

Establishing systematic benchmarks for GenAI serves several key purposes: it sets performance standards and expectations
for model behavior, enables consistent and reliable outputs by identifying when models deviate from expected quality,
and guides improvements by highlighting strengths and weaknesses. Crucially, rigorous benchmarks also support regression
testing–ensuring that as models or prompts are updated, no deterioration in quality occurs @srivastava2020empirical
@trauble2021backward. In enterprise settings, this builds trust that GenAI systems will behave predictably and safely
over time.

For most organizations, responsible and reliable AI use is not just a technical aspiration but a business imperative.
Responsible AI ensures generative models align with company values, regulatory requirements, and stakeholder
expectations. It encompasses principles like fairness, transparency, accountability, and safety @ribeiro2020beyond
@esiobu2023robbie @nist2023ai. It also requires mechanisms to prevent harm and detect model failures before they impact
users.

A formalized benchmarking pipeline is therefore critical to objectively compare models, track progress, validate
improvements, and execute generative AI use cases responsibly. Achieving consistent reliability at scale—especially in
regulated environments—remains one of the greatest challenges in operationalizing GenAI.

== Related Work

Multiple community efforts highlight the need for standardized evaluation of generative models. Stanford's Holistic
Evaluation of Language Models (HELM) provides a "living benchmark" covering various scenarios and metrics for language
models @liang2022holistic. HELM adopts a multi-metric approach, including accuracy, robustness and fairness to assess
capabilities comprehensively, emphasizing the importance of evaluating GenAI across multiple dimensions beyond accuracy.

Industry initiatives like OpenAI's Evals framework offer tools to create custom evaluation datasets and registry
benchmarks for GenAI @openai2023gpt4, reinforcing that high-quality evaluations are essential. Our work builds on these
foundations by focusing on an end-to-end workflow pipeline specifically designed for data scientists in enterprise
contexts. This pipeline combines technical rigor through statistical confidence and automation with practical
considerations such as tooling, domain-specific cases, and responsible AI.

Additionally, emerging practices such as AI-as-a-Judge, using a model to evaluate another model’s output, have been
explored as advanced evaluation techniques @liu2023geval @koutchemen2024open @zheng2023judging. Our paper ties these
threads together by proposing a cohesive benchmarking workflow, demonstrating it through real use cases, and aligning
with responsible AI evaluation standards @nist2023ai.

= Benchmark Workflow Pipeline

This section outlines the proposed pipeline for benchmarking generative AI systems, describing each stage from data
preparation to ongoing regression tests and monitoring.

== Ground Truth Generation <sec:ground-truth>

The foundation of this effort is creating a grounding dataset: a curated collection of examples that establish quality
standards for performance in the specific enterprise context. This dataset is developed through close collaboration with
business users and subject matter experts.

For each use case, a set of inputs and their ideal outputs is compiled and validated by human domain experts. Human
expertise ensures answers are accurate, contextually appropriate, and representative of real user needs
@stiennon2020learning. A robust ground truth serves as the benchmark standard for model performance. This critical step
is often overlooked when enterprises adopt off-the-shelf solutions. Without this grounding, evaluations remain
subjective and disconnected from business requirements.

When testing a GenAI system, we cannot feasibly check every document that will ever be processed. Instead, we test a
representative sample and use statistical methods to estimate overall system performance. A critical question in this
process is determining appropriate sample size. The sample size calculation balances confidence in results against
resource constraints. A larger sample provides greater statistical confidence but increases testing costs and time. We
calculate appropriate sample sizes using power analysis @eq:sample-size, considering desired confidence levels and
acceptable margins of error @goldenholz2024recommendations.

$ n = (Z^2 times p times (1-p)) / E^2 $ <eq:sample-size>

Where:
- $n$ = required sample size
- $Z$ = Z-score for your desired confidence level
- $p$ = expected proportion
- $E$ = margin of error
\

For a finite population, we adjust this using:
$ n_"adjusted" = n / (1 + (n-1)/N) $

The required sample size increases with desired confidence level and decreases with acceptable margin of error.
Importantly, as the total population size increases, the required sample size approaches an asymptotic maximum
(@fig:sample-size)—a counterintuitive finding that highlights the efficiency of proper sampling techniques.

#figure(
  placement: none,
  scope: "column",
  caption: [Required sample size ($n$) as a function of the total population size ($N$) with a desired margin of error fixed at 5%.],
  image("static/sample-size.svg", width: 100%),
) <fig:sample-size>

While humans should lead ground truth creation, AI-assisted tools can propose initial drafts for expert review and
correction. This semi-automated approach streamlines the process while maintaining quality. However, all AI-generated
content must undergo strict human validation to ensure accuracy and relevance to the enterprise context
@novikova2017why.

To be effective, the ground truth must cover diverse scenarios and edge cases. The dataset should reflect realistic
input variations to thoroughly test model robustness. Early involvement of domain experts ensures the dataset captures
the nuances of enterprise operations, resulting in benchmarks that truly represent the organization's needs and use
cases.

== Performance Benchmarking <sec:performance-benchmarking>

Building on this foundation, we implement a robust test harness that evaluates model reliability throughout development
using the grounding dataset as a benchmark. This is crucial given GenAI's probabilistic nature, which necessitates
rigorous evaluation beyond simple point estimates.

Our approach begins with defining quantitative metrics suited to the task @celikyilmaz2020evaluation @liu2016how
@novikova2017why. For structured outputs, these may include exact match accuracy or field-level precision and recall
@celikyilmaz2020evaluation @hashimoto2019unifying, while for unstructured outputs, we use metrics that capture quality
such as answer relevance, coherence, contextual accuracy, and factual correctness @celikyilmaz2020evaluation @liu2016how
@novikova2017why. These metrics form the backbone of our evaluation framework, providing consistent measurement across
model iterations.

To move beyond simplistic evaluations and ensure statistical validity, we report confidence intervals to quantify
uncertainty in performance estimates @raschka2022confidence. This helps distinguish genuine performance differences from
random variation, especially when comparing model versions. The confidence interval represents the reliability range
within which the true accuracy likely falls. Wider intervals indicate greater uncertainty, typically resulting from
smaller sample sizes. For proportion-based metrics, we employ the Wilson score interval @eq:wilson-score to calculate
95% confidence bounds, which provides more accurate coverage than normal approximations, particularly for moderate
sample sizes or metrics near boundary values @brown2001interval. For continuous metrics such as LLM judge scores or
BLEU, we utilize bootstrap resampling to estimate confidence ranges.

$ hat(p) + (z^2)/(2n) plus.minus z sqrt((hat(p)(1-hat(p)))/n + (z^2)/(4n^2)) / (1 + (z^2)/n) $ <eq:wilson-score>

Where:
- $hat(p)$ is the observed proportion
- $z$ is the z-score for the desired confidence level
- $n$ is the sample size
\

The practical implication of confidence interval reporting is significant: fields or metrics with wider confidence
intervals require additional testing to establish their true performance. This information guides efficient resource
allocation, suggesting where to collect additional examples based on business importance and current uncertainty levels.
Higher confidence levels (e.g., 99% vs. 95%) produce wider intervals, representing the trade-off between certainty and
precision. This statistical approach to performance reporting transforms point estimates into ranges that acknowledge
inherent uncertainty, providing decision-makers with a more complete picture of model capabilities and limitations.

#figure(
  placement: none,
  scope: "column",
  caption: [Confidence interval computed using the Wilson score method. The shaded area represents the 95% confidence interval for
    an observed proportion $hat(p) = 50%$.],
  image("static/confidence-interval.svg", width: 100%),
) <fig:confidence-interval>

While metrics provide quantitative assessment, implementation requires both automated and human evaluation components.
We automate evaluation where feasible, enhancing reference-based metrics with LLM-based evaluators for subjective
criteria @liu2023geval @koutchemen2024open. However, human review remains essential, particularly for nuanced
assessments @novikova2017why, creating a complementary evaluation approach that leverages both computational efficiency
and human judgment. The benchmark execution involves running models on the entire test set and calculating summary
statistics for each metric, potentially categorized by sub-groups, thus providing structured, repeatable evaluation
through both quantitative metrics and qualitative assessments.

Finally, to translate technical results into actionable insights, we present findings through clear visualizations that
highlight performance across key dimensions, enabling stakeholders to understand model strengths and limitations at a
glance, bridging the gap between technical evaluation and business decision-making.

== Continuous Monitoring <sec:monitoring>

As AI systems operate in dynamic environments, benchmarking must be integrated into the development cycle and continue
post deployment. Version comparison, or regression testing, should be conducted whenever the model, prompt, or system is
updated. Results should be tracked over time using monitoring tools like MLflow @zaharia2018accelerating to compare
metrics against prior versions and prevent performance drops, enabling confident iterative development
@srivastava2020empirical @trauble2021backward. Automated alerts should be implemented to trigger when key metrics fall
below baseline thresholds, potentially integrating into continuous integration pipelines.

To distinguish meaningful changes from statistical noise, our regression testing framework implements significance tests
to determine whether performance changes between versions represent genuine improvements or degradations rather than
random fluctuations @dror2018hitchhiker. This statistical approach helps prevent both false alarms and missed
regressions, improving the reliability of the monitoring system itself. Building on this foundation, automated alerts
should be implemented to trigger when key metrics fall below baseline thresholds, potentially integrating into
continuous integration pipelines for early detection of issues before they impact end users.

The scale of production AI systems necessitates specialized monitoring capabilities. These include automated
assessments, possibly using LLMs as initial judges for evaluating model outputs at scale—a cost-effective approach to
wide coverage. When discrepancies occur or confidence is low, escalation to human judges ensures quality control
continues at scale while identifying edge cases. This tiered monitoring approach balances computational efficiency with
evaluation depth through frequent lightweight checks supplemented by periodic comprehensive evaluations, optimizing
resource utilization while maintaining quality standards.

To ensure long-term relevance and improvement, the benchmarking process should incorporate a feedback loop where
discovered failures or new scenarios from monitoring or production feedback are added to the grounding dataset and test
harness @kiela2021dynabench @liang2022holistic. This adaptive approach strengthens future iterations and improves
reliability while maintaining a stable core set for long-term tracking. Historical performance logging using tools like
MLflow creates a record of each benchmark run, providing not only a history for trend analysis but also crucial evidence
for compliance and governance requirements in regulated industries.

As business needs evolve, the monitoring system must evolve as well. We recommend periodic reviews of the monitoring
metrics themselves, as business requirements and data distributions may shift over time. This meta-evaluation ensures
the benchmarking system continues to measure what matters most to the organization's objectives, completing a virtuous
cycle of continuous improvement that spans both the AI system and its evaluation framework.

= Use Case Demonstrations

This section illustrates the practical application of our benchmarking workflow through two distinct scenarios: (1) a
structured document processing task extracting information from address change forms, and (2) an unstructured chatbot
task evaluating a question-answering system augmented with document retrieval. For each scenario, we demonstrate how the
benchmark pipeline measures model performance, upholds responsible AI principles, and detects regressions using
domain-specific ground truth.

== Use Case 1: Structured Document Processing Task

In this use case, we apply multimodal GenAI models to extract structured information from unstructured documents.
Specifically, the system processes address change forms, identifies relevant fields and validates the extracted data
against predefined rules (@fig:idp-overview). This task represents a common enterprise challenge where automation can
significantly reduce manual data entry while maintaining accuracy in customer records.

#figure(
  placement: none,
  scope: "column",
  caption: [Structured document processing task overview. We provide an address change form (left) and the system extracts the
    required fields (right).],
  image("static/idp-overview.svg", width: 100%),
) <fig:idp-overview>

As previously described, the benchmark workflow begins by establishing a reliable ground truth dataset. We first
calculated the optimal sample size based on expected production volume using the methodology described in
@sec:ground-truth. For a target confidence level of 95% with a 5% margin of error, we determined a required sample size
of 275 documents.

We curated a diverse document collection with variations in format, layout complexity, and image quality to ensure
representation of real-world scenarios. The annotation schema was then developed collaboratively with business
stakeholders to ensure alignment with operational requirements. This schema defined the expected format and validation
rules for each extracted field, establishing clear standards for what constitutes correct extraction. We then used the
curated documents and the developed schema to make initial calls to the GenAI system, populating baseline values for the
fields of interest (@fig:idp-parameters).

#figure(
  placement: none,
  scope: "column",
  caption: [The ground truth dataset is created by providing curated documents, the required schema, and prompt (top) to the GenAI
    system (middle) to extract the corresponding fields (bottom).],
  image("static/idp-parameters-vertical.svg", width: 95%),
) <fig:idp-parameters>

Subject matter experts then annotated the baseline values to establish the ground truth. To facilitate this process, we
developed a custom annotation frontend application that allowed users to review and correct model predictions, provide
feedback, and track annotation versions over time (@fig:field-validation).

#figure(
  placement: none,
  scope: "column",
  caption: [The custom annotation frontend application allows users to review and correct model predictions.],
  image("static/field-validation.svg", width: 90%),
) <fig:field-validation>

To evaluate the AI system's deployment readiness, we ran performance benchmarks on curated forms and compared extracted
fields to ground truth using exact string matching and accuracy metrics. @fig:accuracy-table presents the overall
performance including Wilson score confidence intervals as described in @sec:performance-benchmarking.

#figure(
  placement: none,
  scope: "column",
  caption: [Performance benchmark for structured document processing applied to 275 address change forms in the ground truth
    dataset. The left column displays hierarchical fields, while the right shows error counts and accuracy metrics. The far
    right column visualizes accuracy (white mark) and confidence intervals (blue bar). Bolded fields indicate significant
    differences from the overall accuracy.],
  image("static/accuracy-table.svg", width: 100%),
) <fig:accuracy-table>

The results revealed high accuracy for fields such as document type (100±1%) and customer phone (92±7%), while
performance on representative signature (68±8%), customer signature (71±6%), and customer signature name (66±7%) was
significantly lower compared to other fields. These findings indicate that the model performs well on fields with clear
formats but struggles with handwritten content. Additionally, the wider confidence intervals for these more complex
fields indicated greater uncertainty, suggesting a need for additional samples to narrow the confidence range for this
field. These findings provided actionable insights for model improvement, highlighting specific areas requiring targeted
enhancement before deployment.

Finally, we implemented continuous monitoring as described in @sec:monitoring to ensure ongoing reliability. This
included (1) regression testing through automated benchmark execution whenever the model, prompt, or system components
were updated, (2) statistical tracking of performance metrics in MLflow creating a historical record for analysis and
(3) automated alerts when performance metrics fell below established thresholds.

To demonstrate this approach's value, we conducted regression testing after implementing prompt engineering improvements
targeting signature field extraction. The updated system showed an 8% increase in accuracy score. Importantly, the
comprehensive benchmark confirmed this improvement without introducing regressions in other fields.

This use case demonstration suggests that the benchmark workflow effectively provides quantitative assurance for model
deployment decisions, identifies specific weaknesses for targeted improvement, and establishes a framework for ongoing
performance monitoring (@fig:workflow-overview). As a result, stakeholders can make informed decisions about deployment
readiness with a clear understanding of performance reliability.

#figure(
  placement: none,
  scope: "column",
  caption: [Benchmark workflow applied to the structured document processing task.],
  image("static/idp-benchmark-workflow.svg", width: 30%),
) <fig:workflow-overview>

== Use Case 2: Unstructured Chatbot Task

🏗️ Work in progress 🏗️

// Business Case

// Ground Truth Generation

// Performance Benchmarking

// Continuous Monitoring

= Discussion

Our benchmarking workflow for generative AI systems addresses the critical gap between AI capability and enterprise
reliability. The implementation across two distinct use cases demonstrates how organizations can systematically
evaluate, improve, and monitor GenAI systems in production environments.

== Key Findings and Implications

The structured document processing task revealed significant performance variations across field types, with handwritten
content proving particularly challenging. The statistical approach using confidence intervals effectively identified
which fields required additional samples for reliable assessment. Our approach bridges theoretical frameworks like HELM
@liang2022holistic with practical enterprise implementation needs, addressing domain adaptation, statistical validation,
and continuous monitoring essential for deployment in regulated environments.

== Strengths of the Proposed Workflow

The primary strength lies in the end-to-end nature of our workflow, connecting ground truth generation through
performance evaluation to continuous monitoring. The emphasis on statistical rigor—through sample size estimation,
confidence interval reporting, and significance testing—provides a sound foundation for deployment decisions.
Additionally, integrating both automated metrics and human evaluation creates a balanced assessment approach capturing
both quantifiable performance and nuanced quality judgments.

== Limitations and Challenges

Despite its strengths, our workflow faces several important limitations. Organizations must balance statistical power
with practical constraints like annotation costs and compute resources. Enterprise data used for benchmarking requires
appropriate anonymization and compliance with data sharing policies. Subject matter expert input is crucial but
represents a significant time investment from skilled personnel. Dimensions like ethical alignment and bias remain
challenging to quantify through automated metrics alone. Fixed benchmarks can become stale as data distributions and
business requirements evolve. The inherent variability of generative models creates challenges for consistent
evaluation.

== Future Directions

Building on our current workflow, we identify several promising directions. Moving toward section-level or
field-specific assessment would provide more targeted feedback for model improvement. Using GenAI systems themselves to
generate challenging test cases could potentially reduce SME workload in ground truth creation. Incorporating real user
feedback into evolving evaluation datasets would maintain relevance to actual usage patterns. Explicitly integrating
bias detection, robustness testing, and ethical compliance checks into standard benchmark suites would align with
evolving standards for AI quality.

= Conclusion

Our benchmarking workflow provides a systematic approach to evaluation that balances statistical rigor with practical
implementation. As generative AI transforms enterprise operations, robust benchmarking becomes not merely a technical
best practice but a business necessity. Organizations implementing comprehensive benchmarking workflows will be better
positioned to deploy GenAI systems that consistently meet performance, reliability, and responsible AI
standards—delivering greater business value while managing associated risks.