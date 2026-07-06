import os,re,sys
D=r"C:\\Users\\nayak\\phase1_docs"
files=sorted(f for f in os.listdir(D) if re.match(r"\d+\-.*\.txt",f))
docs={}
for f in files:
 p=os.path.join(D,f)
 doc_id=f.split("-")[0]
 if doc_id not in docs:docs[doc_id]=[]
 docs[doc_id].append(open(p,encoding="utf-8").read())
map={"0":"00_README.md","1":"01_architecture_overview.md","2":"02_module_dependency_graph.md","3":"03_clock_domains.md","4":"04_memory_map.md","5":"05_rendering_pipeline.md","6":"06_control_fsm.md","7":"07_video_pipeline.md","8":"08_fixed_point_formats.md"}
for k,v in docs.items():
 open(os.path.join(D,map.get(k,"doc"+k+".md")),"w",encoding="utf-8").write("".join(v))
 print(map.get(k,"doc"+k+".md"))
