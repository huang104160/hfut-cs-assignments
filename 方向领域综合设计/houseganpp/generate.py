import numpy as np
import torch
from models.models import Generator
from misc.utils import _init_input, draw_masks, draw_graph
from torchvision.utils import save_image

model = Generator()
model.load_state_dict(torch.load('./checkpoints/pretrained.pth'), strict=True)
model = model.eval()

if torch.cuda.is_available():
    model.cuda()

Tensor = torch.cuda.FloatTensor if torch.cuda.is_available() else torch.FloatTensor

# run inference
def _infer(graph, model, prev_state=None):
    # configure input to the network
    z, given_masks_in, given_nds, given_eds = _init_input(graph, prev_state)
    # run inference model
    with torch.no_grad():
        masks = model(z.to('cuda'), given_masks_in.to('cuda'), given_nds.to('cuda'), given_eds.to('cuda'))
        masks = masks.detach().cpu().numpy()
    return masks

def generate(nds, eds):
    nds = torch.tensor(nds)
    eds = torch.tensor(eds)
    print(nds)
    print(eds)

    real_nodes = np.where(nds.detach().cpu() == 1)[-1]
    graph = [nds, eds]
    true_graph_obj, graph_im = draw_graph([real_nodes, eds.detach().cpu().numpy()])
    graph_im.save('./dump/graph_generate.png')  # save graph

    # add room types incrementally
    _types = sorted(list(set(real_nodes)))
    selected_types = [_types[:k + 1] for k in range(10)]
    _round = 0

    # initialize layout
    state = {'masks': None, 'fixed_nodes': []}
    masks = _infer(graph, model, state)
    im0 = draw_masks(masks.copy(), real_nodes)
    im0 = torch.tensor(np.array(im0).transpose((2, 0, 1))) / 255.0
    # save_image(im0, './dump/fp_init_generate.png', nrow=1, normalize=False) # visualize init image

    # generate per room type
    for _iter, _types in enumerate(selected_types):
        _fixed_nds = np.concatenate([np.where(real_nodes == _t)[0] for _t in _types]) \
            if len(_types) > 0 else np.array([])
        state = {'masks': masks, 'fixed_nodes': _fixed_nds}
        masks = _infer(graph, model, state)

    # save final floorplans
    imk = draw_masks(masks.copy(), real_nodes)
    imk = torch.tensor(np.array(imk).transpose((2, 0, 1))) / 255.0
    save_image(imk, './dump/fp_final_generate.png', nrow=1, normalize=False)
