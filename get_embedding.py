import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import seaborn as sns
from sklearn.metrics.pairwise import cosine_similarity
from scipy.io import savemat


def get_glove_embedding(filepath, target_word):
    with open(filepath, 'r', encoding='utf8') as f:
        for line in f:
            tokens = line.strip().split()
            word = tokens[0]
            if word == target_word:
                vector = [float(val) for val in tokens[1:]]
                return vector
    return None

filename = "D:\\下载\\glove.2024.wikigiga.100d\\wiki_giga_2024_100_MFT20_vectors_seed_2024_alpha_0.75_eta_0.05.050_combined.txt"
short_list = ['egg','pig','bus','car','fish','leaf']
medium_list = ['rocket','monkey','tiger','tractor','apple','indian']
long_list = ['fire engine','elephant','umbrella','helicopter','kangaroo','banana']





embeddings = [[]] * 6
i = 0
for w in short_list:
    embeddings[i] = get_glove_embedding(filename, w)
    i = i + 1

X = np.vstack(embeddings)  # shape: (6, dim)
short_matrix = cosine_similarity(X)
savemat('short_matrix.mat', {'short_matrix': short_matrix})

# heatmap
mask = np.triu(np.ones_like(short_matrix, dtype=bool), k=1)

plt.figure(figsize=(8,6))
ax = sns.heatmap(short_matrix, 
                 mask=mask,
                 xticklabels=short_list, 
                 yticklabels=short_list, 
                 annot=True, 
                 cmap='RdYlBu_r', 
                 vmin=0, vmax=1,
                 linewidths=0,
                 linecolor='gray',
                 annot_kws={"weight": "bold", "size":10},
                 square=True)

# 关闭坐标轴边框线
for spine in ax.spines.values():
    spine.set_visible(False)

plt.title('Cosine Similarity Heatmap for Short List', fontsize=16, weight='bold')
plt.xticks(rotation=45, fontsize=12)
plt.yticks(rotation=0, fontsize=12)
plt.tight_layout()
plt.show()


embeddings = [[]] * 6
i = 0
for w in medium_list:
    embeddings[i] = get_glove_embedding(filename, w)
    i = i + 1

X = np.vstack(embeddings)  # shape: (6, dim)
medium_matrix = cosine_similarity(X)
print(medium_matrix)
savemat('medium_matrix.mat', {'medium_matrix': medium_matrix})



embeddings = [[]] * 6
i = 0
for w in long_list:
    if w == 'fire engine':
        embeddings[i] = (np.array(get_glove_embedding(filename, 'fire')) + np.array(get_glove_embedding(filename, 'engine'))) / 2
    else:
        embeddings[i] = get_glove_embedding(filename, w)
    i = i + 1

X = np.vstack(embeddings)  # shape: (6, dim)
long_matrix = cosine_similarity(X)

print(long_matrix)
savemat('long_matrix.mat', {'long_matrix': long_matrix})
